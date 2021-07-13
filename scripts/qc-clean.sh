#!/bin/bash

#SBATCH --job-name=qc-clean
#SBATCH --mail-user=gtesto@tgen.org
#SBATCH --mail-type=END,FAIL
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
conda activate kneaddata-0.7.4

# Create output folders
mkdir reports/fastqc/after_trimming
mkdir reports/multiqc/after_trimming

# Run quality control check on trimmed sequence reads
fastqc -t 8 results/paired/*.fastq --outdir=reports/fastqc/after_trimming
multiqc reports/fastqc/after_trimming --outdir=reports/multiqc/after_trimming

# Deactivate QC conda environment
conda deactivate
