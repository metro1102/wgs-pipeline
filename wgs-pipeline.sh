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
#                                Initalization                                #
###############################################################################

source config.sh
source functions.sh

# Check Setup #################################################################

if [ ! -z "$WGS" ]; then

    initLog "WGS pipeline directory has been specified as '${WGS}'..."

elif [ -z "$WGS" ]; then

    errorLog "Please specify a WGS pipeline directory for your setup!"

    exit

fi

sleep 5

if [ ! -z "$PROJECTS" ]; then

    initLog "Projects directory has been specified as '${PROJECTS}'..."

elif [ -z "$PROJECTS" ]; then

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

if [[ $FRAGMENT_TYPE = "paired" ]] || [[ $FRAGMENT_TYPE = "single" ]]; then

    infoLog "Running sequence read(s) in ${FRAGMENT_TYPE} end mode..."

elif [[ $FRAGMENT_TYPE != "paired" ]] || [[ $FRAGMENT_TYPE != "single" ]]; then

    errorLog "Please specify if your reads are 'paired' or 'single' end!"

    exit

elif [ -z "$FRAGMENT_TYPE" ]; then

    errorLog "Please specify the type of reads that you have ['paired' or 'single']!"

    exit

fi

sleep 5

if [[ $PIPELINE = "kraken2" ]] || [[ $PIPELINE = "metaphlan" ]]; then

    infoLog "Running the ${PIPELINE} workflow..."

    sleep 5

    # If using kraken2, verify if required database path exists

    if [[ $PIPELINE = "kraken2" ]] && [[ -z "$KRAKEN2DB" ]]; then

        errorLog "Please provide a full path to your kraken2 database!"

        exit

    fi

    # If using metaphlan, verify if required database path exists

    if [[ $PIPELINE = "metaphlan" ]] && [[ -z "$BOWTIE2DB" ]]; then

        errorLog "Please provide a full path to your metaphlan (bowtie2) database!"

        exit

    fi

elif [[ $PIPELINE != "kraken2" ]] || [[ $PIPELINE != "metaphlan" ]]; then

    errorLog "Please set your desired pipeline to 'kraken2' or 'metaphlan'!"

    exit

elif [ -z "$PIPELINE" ]; then

    errorLog "Please set a desired pipeline ['kraken2' or 'metaphlan']!"

    exit

fi

sleep 5

if [[ $ANALYSIS = "WGS" ]] || [[ $ANALYSIS = "16S" ]]; then

    infoLog "Running ${ANALYSIS} for downstream analyses..."

    if [[ $PIPELINE = "metaphlan" ]] && [[ $ANALYSIS = "16S" ]]; then

        errorLog "Please set your desired downstream analysis to 'WGS'!"

        exit
    fi

elif [[ $ANALYSIS != "WGS" ]] || [[ $ANALYSIS != "16S" ]]; then

    errorLog "Please set your desired downstream analysis as 'WGS' or '16S'!"

    exit

elif [ -z "$ANALYSIS" ]; then

    errorLog "Please set a desired downstream analysis ['WGS' or '16S']!"

    exit

fi

# Run Setup ###################################################################

export WGS=${WGS}

cd ${PROJECTS}/${PROJECT_NAME}

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

if [[ $PIPELINE = "kraken2" ]]; then

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

elif [[ $PIPELINE = "metaphlan" ]]; then

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
mkdir slurm/archive

mv *.out slurm
mv ${WGS}/*.out ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/slurm

cd slurm

TODAY=$(date +"%Y%m%d")
cat *.out > ${TODAY}-${SAMPLE_TYPE}.log | sed 's/\x1b\[[0-9;]*m//g'

mv *.out archive

cd ..

unset WGS
