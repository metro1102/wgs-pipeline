#!/bin/bash

#SBATCH --job-name=bracken
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:30:00

# Load source(s)
source "../../config.sh"
source "../../functions.sh"

# Initate bash shell using conda
source ~/.bashrc

conda activate kraken2

mkdir results/kraken2/bracken
mkdir reports/kraken2/bracken

cd reports/kraken2

for i in *_report.kraken;
do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   bracken -d ${KRAKEN2DB} -r ${BRACKEN_READ_LEN} -l S -i $i -o bracken/${fname}_species_output.bracken -w bracken/${fname}_species_report.bracken;
done

for i in *_report.kraken;
do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   bracken -d ${KRAKEN2DB} -r ${BRACKEN_READ_LEN} -l G -i $i -o bracken/${fname}_genus_output.bracken -w bracken/${fname}_genus_report.bracken;
done

for i in *_report.kraken;
do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   bracken -d ${KRAKEN2DB} -r ${BRACKEN_READ_LEN} -l P -i $i -o bracken/${fname}_phylum_output.bracken -w bracken/${fname}_phylum_report.bracken;
done

cd bracken

# This step is necessary, and we should combine outputs from kraken2 & bracken
# Because reads shouldn't be combined before processing, this step is important
combine_bracken_outputs.py --files *species_output.bracken -o all_species_output.bracken
combine_bracken_outputs.py --files *genus_output.bracken -o all_genus_output.bracken
combine_bracken_outputs.py --files *phylum_output.bracken -o all_phylum_output.bracken

mv *_output.bracken ../../../results/kraken2/bracken

# Deactivate kraken2 conda environment
conda deactivate

cd ../../../
