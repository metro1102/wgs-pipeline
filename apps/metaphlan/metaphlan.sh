#!/bin/bash

#SBATCH --job-name=metaphlan
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=10G
#SBATCH --time=72:00:00

# Load source(s)
source "${WGS}/config.sh"
source "${WGS}/functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate metaphlan conda environment
conda activate metaphlan-3.0.10

# Create output folders
mkdir results/bowtie2
mkdir reports/metaphlan

# Run metaphlan on available trims
for i in results/paired/*_paired_1.fastq
do
   filename=$(basename "$i")
   fname="${filename%_paired_*.fastq}";
   metaphlan --bowtie2db ${BOWTIE2DB} results/paired/${fname}_paired_1.fastq,results/paired/${fname}_paired_2.fastq --input_type fastq --bowtie2out results/bowtie2/${fname}.bowtie2.bz2 -o reports/metaphlan/${fname}.txt
done

cd reports/metaphlan

merge_metaphlan_tables.py * > merged_abundance_table.txt

grep -E "s__|clade" merged_abundance_table.txt | sed 's/^.*s__//g'\
    | cut -f1,3-8 | sed -e 's/clade_name/SampleID/g' > merged_abundance_table_species.txt

# Move & rename merged_abundance_table_species
mv merged_abundance_table_species.txt ../../${ANALYSIS}-${SAMPLE_TYPE}-metaphlan-results.txt

# Deactivate metaphlan conda environment
conda deactivate

cd ../../
