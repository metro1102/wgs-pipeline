#!/bin/bash

#SBATCH --job-name=wgs-pipeline
#SBATCH --mail-user=gtesto@tgen.org
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=120:00:00

###############################################################################
#                                    Setup                                    #
###############################################################################

# Configure the following settings:
WGS="/labs/Microbiome/gtesto/scripts/wgs-pipeline"   # Path for this program.

ROOT="/scratch/gtesto/projects/"    # Root directory for your projects.
PROJECT_NAME="clinical"             # Project name that you are working on.
SAMPLE_TYPE="saliva"                # Sample type for your working reads.
FRAGMENT_TYPE="paired"              # If reads are "single" or "paired".
PIPELINE="kraken2"                  # Pipeline ("kraken2" or "metaphlan").

# If using kraken2 or metaphlan, please specify a database path to use.
KNEADDATADB="/labs/Microbiome/gtesto/databases/kneaddata/human_genome"
KRAKEN2DB="/labs/Microbiome/gtesto/databases/kraken2/silva_16S_SSU"
BOWTIE2DB="/labs/Microbiome/gtesto/databases/humann/bowtie2"


###################### ! DO NOT EDIT BEYOND THIS POINT ! ######################


###############################################################################
#                                Initalization                                #
###############################################################################

# Setup Logging ###############################################################

initLog() { # Init Log (for initalization messages)
    echo -e "\e[37m""INIT - $1""\e[0m"
}

infoLog() { # Info Log (for task specific messages)
    echo -e "\e[36m""INFO - $1""\e[0m"
}

errorLog() { # Error log (for error messages)
    echo -e "\e[91m""ERROR - $1""\e[0m"
}

# Setup Environment ###########################################################

export WGS="$WGS"

export ROOT="$ROOT"
export PROJECT_NAME="$PROJECT_NAME"
export SAMPLE_TYPE="$SAMPLE_TYPE"
export FRAGMENT_TYPE="$FRAGMENT_TYPE"
export PIPELINE="$PIPELINE"

export KNEADDATADB="$KNEADDATADB"
export KRAKEN2DB="$KRAKEN2DB"
export BOWTIE2DB="$BOWTIE2DB"

export -f initLog
export -f infoLog
export -f errorLog

# Check Setup #################################################################

if [ ! -z "$WGS" ]; then

    initLog "WGS pipeline directory has been specified as '${WGS}'..."

elif [ -z "$WGS" ]; then

    errorLog "Please specify a WGS pipeline directory for your setup!"

    exit

fi

sleep 5

if [ ! -z "$ROOT" ]; then

    initLog "Root directory has been specified as '${ROOT}'..."

elif [ -z "$ROOT" ]; then

    errorLog "Please specify a root directory for your projects!"

    exit

fi

sleep 5

if [ ! -z "$PROJECT_NAME" ]; then

    initLog "Project name has been specified as '${PROJECT_NAME}'..."

elif [ -z "$PROJECT_NAME" ]; then

    errorLog "Please specify a project name!"

    exit

fi

sleep 5

if [ ! -z "$SAMPLE_TYPE" ]; then

    initLog "Sample type has been specified as '${SAMPLE_TYPE}'..."

elif [ -z "$SAMPLE_TYPE" ]; then

    errorLog "Please specify the sample type for your working reads!"

    exit

fi

sleep 5

if [ FRAGMENT_TYPE="paired" ] || [ FRAGMENT_TYPE="single"]; then

    infoLog "Running sequence read(s) in ${FRAGMENT_TYPE} end mode..."

elif [ -z "$FRAGMENT_TYPE" ]; then

    errorLog "Please specify the type of reads that you have ['paired' or 'single']!"

    exit

fi

sleep 5

if [ PIPELINE="kraken2" ] || [ PIPELINE="metaphlan" ]; then

    infoLog "Running the ${PIPELINE} workflow..."

    sleep 5

    # If using kraken2, verify if required database path exists

    if [ PIPELINE="kraken2" ] && [ -z "$KRAKEN2DB" ]; then

        errorLog "Please provide a full path to your kraken2 database!"

        exit

    fi

    # If using metaphlan, verify if required database path exists

    if [ PIPELINE="metaphlan" ] && [ -z "$BOWTIE2DB" ]; then

        errorLog "Please provide a full path to your metaphlan (bowtie2) database!"

        exit

    fi

elif [ -z "$PIPELINE" ]; then

    errorLog "Please set a desired pipeline ['kraken2' or 'metaphlan']!"

    exit

fi

# Run Setup ###################################################################

# Navigate to project and samples folder
cd ${ROOT}${PROJECT_NAME}

mkdir ${SAMPLE_TYPE}

cd ${SAMPLE_TYPE}

mkdir results
mkdir reports

###############################################################################
#                            Quality Control (RAW)                            #
###############################################################################

infoLog "Running raw sequence read(s) through quality control..."

prev_job=$(sbatch --wait ${WGS}/scripts/qc-raw.sh | sed 's/Submitted batch job //')

###############################################################################
#                                Run kneaddata                                #
###############################################################################

infoLog "Running raw sequence read(s) through kneaddata..."

prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/kneaddata/kneaddata.sh | sed 's/Submitted batch job //')

###############################################################################
#                           Quality Control (CLEAN)                           #
###############################################################################

infoLog "Running processed sequence read(s) through quality control..."

prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/qc-clean.sh | sed 's/Submitted batch job //')

###############################################################################
#                        Additional Pipeline Script(s)                        #
###############################################################################

if [ PIPELINE="kraken2" ]; then

    ###########################################################################
    #                               Run kraken2                               #
    ###########################################################################

    infoLog "Running processed sequence read(s) through kraken2..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/kraken2/kraken2.sh | sed 's/Submitted batch job //')

    ###########################################################################
    #                               Run bracken                               #
    ###########################################################################

    infoLog "Running kraken2 reports through bracken..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/kraken2/bracken.sh | sed 's/Submitted batch job //')

    ###########################################################################
    #                                Run krona                                #
    ###########################################################################

    infoLog "Running kraken2 & bracken reports through krona..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/kraken2/krona.sh | sed 's/Submitted batch job //')

    ###########################################################################
    #                                 Run biom                                #
    ###########################################################################

    infoLog "Generating a biom file from bracken species reports..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/kraken2/biom.sh | sed 's/Submitted batch job //')

elif [ PIPELINE="metaphlan" ]; then

    ###########################################################################
    #                              Run metaphlan                              #
    ###########################################################################

    infoLog "Running processed sequence read(s) through metaphlan..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/metaphlan/metaphlan.sh | sed 's/Submitted batch job //')

    ##########################################################################
    #                                Run krona                               #
    ##########################################################################

    infoLog "Running metaphlan merged_abundance_table through krona..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/metaphlan/krona.sh | sed 's/Submitted batch job //')

    ###########################################################################
    #                               Run hclust2                               #
    ###########################################################################

    infoLog "Running metaphlan results through hclust2 for abundance heatmapping for species..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job ${WGS}/scripts/metaphlan/hclust2.sh | sed 's/Submitted batch job //')

fi

###############################################################################
#                                 Termination                                 #
###############################################################################

# Compile Logs ################################################################

mkdir slurm

mv *.out slurm
mv ${WGS}/*.out ${ROOT}/${PROJECT_NAME}/${SAMPLE_TYPE}/slurm

cd slurm

TODAY=$(date +"%Y%m%d")
cat *.out > ${TODAY}-${SAMPLE_TYPE}.log | sed 's/\x1b\[[0-9;]*m//g'

cd ..

# Disassemble Environment #####################################################

unset WGS

unset ROOT
unset PROJECT_NAME
unset SAMPLE_TYPE
unset FRAGMENT_TYPE
unset PIPELINE

unset KNEADDATADB
unset KRAKEN2DB
unset BOWTIE2DB

unset -f initLog
unset -f infoLog
unset -f errorLog
