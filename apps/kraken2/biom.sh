#!/bin/bash

#SBATCH --job-name=biom
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:05:00

# Load source(s)
source "../../config.sh"
source "../../functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate biom conda environment
conda activate biom

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}

cd reports/kraken2/${DATABASE_NAME}

# Temporarily copy & rename kraken reports
mkdir temp

for i in *_report.kraken
do
    filename=$(basename "$i")
    fname="${filename%_report.kraken}"
    cp ${filename} temp/${fname}.kraken
done

cd temp

# Generate biom format & summarize the results
kraken-biom *.kraken -o sequences.biom --fmt json

infoLog "Generating a biom file summary for kraken results..."

biom summarize-table -i sequences.biom -o sequences-summary.txt

# Move biom files back to the main directory
mv sequences.biom ../../../../
mv sequences-summary.txt ../../../../

# Remove temporary folder
cd .. && rm -r temp

cd ../../../

# Rename biom files to sample type
mv sequences.biom ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-results.biom
mv sequences-summary.txt ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-summary.txt

cd reports/kraken2/${DATABASE_NAME}/bracken

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

infoLog "Generating a biom file summary for bracken results..."

biom summarize-table -i sequences.biom -o sequences-summary.txt

# Deactivate biom conda environment
conda deactivate

# Move biom files back to the main directory
mv sequences.biom ../../../../../
mv sequences-summary.txt ../../../../../

# Remove temporary folder
cd .. && rm -r temp

cd ../../../../

# Rename biom files to sample type
#mkdir results/biom
mv sequences.biom ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-results.biom
mv sequences-summary.txt ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-summary.txt
