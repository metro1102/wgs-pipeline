#!/bin/bash

#SBATCH --job-name=biom
#SBATCH --mail-user=gtesto@tgen.org
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:05:00

# Initate bash shell using conda
source ~/.bashrc

# Activate biom conda environment
conda activate kraken-biom-1.0.1

cd reports/kraken2/bracken

# Temporarily copy & rename bracken species reports
mkdir temp

if [[ $ANALYSIS = "WGS" ]]; then

   for i in *_species_report.bracken
   do
      filename=$(basename "$i")
      fname="${filename%_species_report.bracken}";
      cp ${filename} temp/${fname}.bracken
   done

elif [[ $ANALYSIS = "16S" ]]; then

   for i in *_genus_report.bracken
   do
      filename=$(basename "$i")
      fname="${filename%_genus_report.bracken}";
      cp ${filename} temp/${fname}.bracken
   done

fi

cd temp

# Generate biom format & summarize the results
kraken-biom *.bracken -o sequences.biom --fmt json

infoLog "Generating a biom file summary..."

biom summarize-table -i sequences.biom -o sequences-summary.txt

# Deactivate biom conda environment
conda deactivate

# Move biom files back to the main directory
mv sequences.biom ../../../../
mv sequences-summary.txt ../../../../

# Remove temporary folder
cd .. && rm -r temp

cd ../../../

# Rename biom files to sample type
#mkdir results/biom
mv sequences.biom ${SAMPLE_TYPE}-bracken-results.biom
mv sequences-summary.txt ${SAMPLE_TYPE}-bracken-summary.txt
