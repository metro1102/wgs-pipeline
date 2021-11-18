#!/bin/bash

#SBATCH --job-name=qc-raw
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:30:00

# Load source(s)
source "../config.sh"
source "../functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate QC conda environment
conda activate kneaddata

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${PIPELINE}/${ANALYSIS}

# Create output folders
mkdir reports/fastqc
mkdir reports/multiqc

mkdir reports/fastqc/before_trimming
mkdir reports/multiqc/before_trimming

# Run quality control check on trimmed sequence reads
fastqc -t 8 ../../../reads/${SAMPLE_TYPE}/*.fastq.gz --outdir=reports/fastqc/before_trimming
multiqc reports/fastqc/before_trimming --outdir=reports/multiqc/before_trimming

# Deactivate QC conda environment
conda deactivate
