#!/bin/bash

#SBATCH --job-name=humann
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

# Activate humann conda environment
conda activate humann

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}

# Create output folders
mkdir results/humann

if [[ $FRAGMENT_TYPE = "paired" ]]; then

    mkdir temp

    # Concate reads into single files
    for i in results/paired/*_paired_1.fastq
    do
        filename=$(basename "$i")
        fname="${filename%_paired_*.fastq}"
        cat ${fname}_paired_1.fastq ${fname}_paired_2.fastq > ${fname}.fastq
    done

    mv *.fastq temp/

    # Run humann on available trims
    for i in results/paired/temp/*.fastq
    do
        filename=$(basename "$i")
        fname="${filename%*.fastq}"
        humann --input results/paired/${fname}.fastq --output results/humann/ --nucleotide-database ${HUMANNDB} --protein-database ${UNIREFDB} --threads 8
    done

    rm -r temp/

elif [[ $FRAGMENT_TYPE = "single" ]]; then

    # Run humann on available trims
    for i in results/paired/*.fastq
    do
        filename=$(basename "$i")
        fname="${filename%*.fastq}"
        humann --input results/paired/${fname}.fastq --output results/humann --nucleotide-database ${HUMANNDB} --protein-database ${UNIREFDB} --threads 8
    done

fi

# Join all gene family and pathway abundance files
humann_join_tables --input results/humann --output results/humann/humann_genefamilies.tsv --file_name genefamilies_relab
humann_join_tables --input results/humann --output results/humann/humann_pathcoverage.tsv --file_name pathcoverage
humann_join_tables --input results/humann --output results/humann/humann_pathabundance.tsv --file_name pathabundance_relab

# Normalize RPKs to CPM
humann_renorm_table -i results/humann/humann_genefamilies.tsv -o results/humann/humann_genefamilies_normalized.tsv --units cpm
humann_renorm_table -i results/humann/humann_pathcoverage.tsv -o results/humann/humann_pathcoverage_normalized.tsv --units cpm
humann_renorm_table -i results/humann/humann_pathabundance.tsv -o results/humann/humann_pathabundance_normalized.tsv --units cpm

# Generate stratified tables

