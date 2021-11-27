#!/bin/bash

#SBATCH --job-name=wgs-pipeline
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=72:00:00

###############################################################################
#                                Initalization                                #
###############################################################################

source "./config.sh"
source "./functions.sh"

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

    errorLog "Please specify a sample type for your working reads!"

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

if [[ $TRIMMING = "kneaddata" ]] || [[ $TRIMMING = "trimmomatic" ]]; then

    infoLog "Using ${TRIMMING} for sequence read trimming..."

elif [[ $TRIMMING != "kneaddata" ]] || [[ $TRIMMING != "trimmomatic" ]]; then

    errorLog "Please set your desired trimmer to 'kneaddata' or 'trimmomatic'!"

    exit

elif [ -z "$TRIMMING" ]; then

    errorLog "Please set a desired trimmer ['kneaddata' or 'trimmomatic']!"

    exit

fi

sleep 5

if [[ $PIPELINE = "kraken2" ]] || [[ $PIPELINE = "metaphlan" ]] || [[ $PIPELINE = "humann" ]]; then

    infoLog "Running the ${PIPELINE} workflow..."

    sleep 5

    # If using kraken2, verify if required database path exists

    if [[ $PIPELINE = "kraken2" ]] && [[ -z "$KRAKEN2DB" ]]; then

        errorLog "Please provide a full path to your kraken2 database!"

        exit

    fi

    # If using metaphlan, verify if required database path exists

    if [[ $PIPELINE = "metaphlan" ]] && [[ -z "$METAPHLANDB" ]]; then

        errorLog "Please provide a full path to your metaphlan (bowtie2) database!"

        exit

    fi

    # If using humann, verify if required database path exists

    if [[ $PIPELINE = "humann" ]] && [[ -z "$HUMANNDB" ]]; then

        errorLog "Please provide a full path to your humann (chocophlan) database!"

        exit

    fi

elif [[ $PIPELINE != "kraken2" ]] || [[ $PIPELINE != "metaphlan" ]] || [[ $PIPELINE != "humann" ]]; then

    errorLog "Please set your desired pipeline to ['kraken2', 'metaphlan', or 'humann']!"

    exit

elif [ -z "$PIPELINE" ]; then

    errorLog "Please set a desired pipeline ['kraken2', 'metaphlan', 'humann']!"

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

# Check if sample_type folder exists
if [[ ! -d "${SAMPLE_TYPE}" ]]; then

    mkdir ${SAMPLE_TYPE} && cd ${SAMPLE_TYPE}

elif [[ -d "${SAMPLE_TYPE}" ]]; then

    cd ${SAMPLE_TYPE}

fi

# Check if pipeline folder exists
if [[ ! -d "${PIPELINE}" ]]; then

    mkdir ${PIPELINE} && cd ${PIPELINE}

elif [[ -d "${PIPELINE}" ]]; then

    cd ${PIPELINE}

fi

# Check if analysis folder exists
if [[ ! -d "${ANALYSIS}" ]]; then

    mkdir ${ANALYSIS} && cd ${ANALYSIS}

elif [[ -d "${ANALYSIS}" ]]; then

    cd ${ANALYSIS}

fi

# Check if results folder exists
if [[ ! -d "results" ]]; then

    mkdir results

fi

# Check if reports folder exists
if [[ ! -d "reports" ]]; then

    mkdir reports

fi

###############################################################################
#                            Quality Control (RAW)                            #
###############################################################################

if [[ ! -d "reports/fastqc/before_trimming" ]] && [[ ! -d "reports/multiqc/before_trimming" ]]; then

    infoLog "Running raw sequence read(s) through quality control..."

    prev_job=$(sbatch --wait -D ${WGS}/apps/ ${WGS}/apps/qc-raw.sh | sed 's/Submitted batch job //')

elif [[ -d "reports/fastqc/before_trimming" ]] && [[ -d "reports/multiqc/before_trimming" ]]; then

    infoLog "Skipping quality control for raw sequence read(s)..."

fi

if [[ $TRIMMING = "kneaddata" ]]; then

    ###########################################################################
    #                              Run kneaddata                              #
    ###########################################################################

    if [[ ! -d "reports/kneaddata" ]]; then

        infoLog "Running raw sequence read(s) through kneaddata..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kneaddata/ ${WGS}/apps/kneaddata/kneaddata.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/kneaddata" ]]; then

        infoLog "Skipping kneaddata for raw sequence read(s)..."

    fi

elif [[ $TRIMMING = "trimmomatic" ]]; then

    ###########################################################################
    #                             Run trimmomatic                             #
    ###########################################################################

    if [[ ! -d "results/trimmomatic" ]]; then

        infoLog "Running raw sequence read(s) through trimmomatic..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kneaddata/ ${WGS}/apps/kneaddata/trimmomatic.sh | sed 's/Submitted batch job //')

    elif [[ -d "results/trimmomatic" ]]; then

        infoLog "Skipping trimmomatic for raw sequence read(s)..."

    fi

fi

###############################################################################
#                           Quality Control (CLEAN)                           #
###############################################################################

if [[ ! -d "reports/fastqc/after_trimming" ]] && [[ ! -d "reports/multiqc/after_trimming" ]]; then

    infoLog "Running processed sequence read(s) through quality control..."

    prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/ ${WGS}/apps/qc-clean.sh | sed 's/Submitted batch job //')

elif [[ -d "reports/fastqc/after_trimming" ]] && [[ -d "reports/multiqc/after_trimming" ]]; then

    infoLog "Skipping quality control for processed sequence read(s)..."

fi

###############################################################################
#                        Additional Pipeline Script(s)                        #
###############################################################################

if [[ $PIPELINE = "kraken2" ]]; then

    ###########################################################################
    #                               Run kraken2                               #
    ###########################################################################

    if [[ ! -d "reports/kraken2" ]]; then

        infoLog "Running processed sequence read(s) through kraken2..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kraken2/ ${WGS}/apps/kraken2/kraken2.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/kraken2" ]]; then

        infoLog "Skipping kraken2 for processed sequence read(s)..."

    fi

    ###########################################################################
    #                               Run bracken                               #
    ###########################################################################

    if [[ ! -d "reports/kraken2/bracken" ]]; then

        infoLog "Running kraken2 reports through bracken..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kraken2/ ${WGS}/apps/kraken2/bracken.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/kraken2/bracken" ]]; then

        infoLog "Skipping bracken for kraken2 reports..."

    fi

    ###########################################################################
    #                                Run krona                                #
    ###########################################################################

    if [[ ! -d "reports/krona" ]]; then

        infoLog "Running kraken2 & bracken reports through krona..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kraken2/ ${WGS}/apps/kraken2/krona.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/krona" ]]; then

        infoLog "Skipping krona for kraken2 & bracken reports..."

    fi

    ###########################################################################
    #                                 Run biom                                #
    ###########################################################################

    if [[ ! -f "${ANALYSIS}-${SAMPLE_TYPE}-bracken-results.biom" ]] && [[ ! -f "${ANALYSIS}-${SAMPLE_TYPE}-bracken-summary.txt" ]]; then

        infoLog "Generating biom files from kraken & bracken reports..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kraken2/ ${WGS}/apps/kraken2/biom.sh | sed 's/Submitted batch job //')

    elif [[ -f "${ANALYSIS}-${SAMPLE_TYPE}-bracken-results.biom" ]] && [[ -f "${ANALYSIS}-${SAMPLE_TYPE}-bracken-summary.txt" ]]; then

        infoLog "Skipping biom file generation from kraken & bracken reports..."

    fi

    ###########################################################################
    #                                 Run qiime                               #
    ###########################################################################

    if [[ ! -f "${ANALYSIS}-${SAMPLE_TYPE}-kraken-taxa-barplot.qzv" ]] && [[ ! -f "${ANALYSIS}-${SAMPLE_TYPE}-bracken-taxa-barplot.qzv" ]]; then

        infoLog "Generating qiime2 taxa bar plots from kraken & bracken biom files..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/kraken2/ ${WGS}/apps/kraken2/qiime2.sh | sed 's/Submitted batch job //')

    elif [[ -f "${ANALYSIS}-${SAMPLE_TYPE}-kraken-taxa-barplot.qzv" ]] && [[ -f "${ANALYSIS}-${SAMPLE_TYPE}-bracken-taxa-barplot.qzv" ]]; then

        infoLog "Skipping qiime2 taxa bar plot(s) generation from kraken & bracken biom files..."

    fi

elif [[ $PIPELINE = "metaphlan" ]]; then

    ###########################################################################
    #                              Run metaphlan                              #
    ###########################################################################

    if [[ ! -d "reports/metaphlan" ]]; then

        infoLog "Running processed sequence read(s) through metaphlan..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/metaphlan/ ${WGS}/apps/metaphlan/metaphlan.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/metaphlan" ]]; then

        infoLog "Skipping metaphlan for processed sequence read(s)..."

    fi

    ##########################################################################
    #                                Run krona                               #
    ##########################################################################

    if [[ ! -d "reports/krona" ]]; then

        infoLog "Running metaphlan merged_abundance_table through krona..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/metaphlan/ ${WGS}/apps/metaphlan/krona.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/krona" ]]; then

        infoLog "Skipping krona for metaphlan merged_abundance_table..."

    fi

    ###########################################################################
    #                               Run hclust2                               #
    ###########################################################################

    if [[ ! -d "reports/metaphlan" ]]; then

        infoLog "Running metaphlan results through hclust2 for abundance heatmapping for species..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/metaphlan/ ${WGS}/apps/metaphlan/hclust2.sh | sed 's/Submitted batch job //')

    elif [[ -d "reports/metaphlan" ]]; then

        infoLog "Skipping hclust 2 for metaphlan results..."

    fi

elif [[ $PIPELINE = "humann" ]]; then

    if [[ ! -d "results/humann" ]]; then

        infoLog "Running processed sequence read(s) through humann..."

        prev_job=$(sbatch --wait --dependency=afterok:$prev_job -D ${WGS}/apps/humann/ ${WGS}/apps/humann/humann.sh | sed 's/Submitted batch job //')

    elif [[ -d "results/humann" ]]; then

        infoLog "Skipping humann for processed sequence read(s)..."

    fi
fi

###############################################################################
#                                 Termination                                 #
###############################################################################

# Compile Logs ################################################################

mkdir slurm
mkdir slurm/outputs

cd ${WGS}
mv *.out ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}/slurm

cd apps
mv *.out ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}/slurm

if [[ $PIPELINE = "kraken2" ]]
    cd kraken2
    mv *.out ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}/slurm
    cd ..
elif [[ $PIPELINE = "metaphlan" ]]; then
    cd metaphlan
    mv *.out ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}/slurm
    cd ..
elif [[ $PIPELINE = "humann" ]]; then
    cd humann
    mv *.out ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}/slurm
    cd ..
fi

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}/slurm

TODAY=$(date +"%Y%m%d")
cat *.out > ${TODAY}-${ANALYSIS}-${SAMPLE_TYPE}.log | sed 's/\x1b\[[0-9;]*m//g'

mv *.out outputs

cd ..

unset WGS
