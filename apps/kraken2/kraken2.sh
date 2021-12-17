#!/bin/bash

#SBATCH --job-name=kraken2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=10G
#SBATCH --time=72:00:00

# Load source(s)
source "../../config.sh"
source "../../functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate kraken2 conda environment
conda activate kraken2

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}

# Create output folders
mkdir reports/kraken2
mkdir results/kraken2

mkdir reports/kraken2/${DATABASE_NAME}
mkdir results/kraken2/${DATABASE_NAME}

# Run kraken2 on available reads
if [[ $FRAGMENT_TYPE = "paired" ]]; then

    for i in results/paired/*_paired_1.fastq;
    do
        filename=$(basename "$i");
        fname="${filename%_paired_*.fastq}";
        kraken2 --db ${KRAKEN2DB} --threads 8 --use-names --output results/kraken2/${DATABASE_NAME}/${fname}_output.kraken --report reports/kraken2/${DATABASE_NAME}/${fname}_report.kraken --paired results/paired/${fname}_paired_1.fastq results/paired/${fname}_paired_2.fastq
    done

elif [[ $FRAGMENT_TYPE = "single" ]]; then

    for i in results/single/*.fastq
    do
        filename=$(basename "$i");
        fname="${filename%*.fastq}";
        kraken2 --db ${KRAKEN2DB} --threads 8 --use-names --output results/kraken2/${DATABASE_NAME}/${fname}_output.kraken --report reports/kraken2/${DATABASE_NAME}/${fname}_report.kraken results/single/${fname}.fastq
    done

fi

# Deactivate kraken2 conda environment
conda deactivate
