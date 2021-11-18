#!/bin/bash

#SBATCH --job-name=krona
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

# Activate krona conda environment
conda activate krona

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${PIPELINE}/${ANALYSIS}

# Create output folders
mkdir reports/krona
mkdir reports/krona/kraken2
mkdir reports/krona/bracken

cd reports/kraken2

# Generate krona using species reports from bracken
for i in *_report.kraken;
do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   python ${WGS}/apps/dependencies/KrakenTools/kreport2krona.py -r ${filename} -o ../krona/kraken2/${fname}.krona;
done

ktImportText ../krona/kraken2/*.krona -o ../krona/kraken2.krona.html

cd bracken

if [[ $ANALYSIS = "WGS" ]]; then

   for i in *_species_report.bracken
   do
      filename=$(basename "$i")
      fname="${filename%_species_report.bracken}"
      python ${WGS}/apps/dependencies/KrakenTools/kreport2krona.py -r ${filename} -o ../../krona/bracken/${fname}.krona
   done

elif [[ $ANALYSIS = "16S" ]]; then

   for i in *_genus_report.bracken
   do
      filename=$(basename "$i")
      fname="${filename%_genus_report.bracken}"
      python ${WGS}/apps/dependencies/KrakenTools/kreport2krona.py -r ${filename} -o ../../krona/bracken/${fname}.krona
   done

fi

ktImportText ../../krona/bracken/*.krona -o ../../krona/bracken.krona.html

# Deactivate krona conda environment
conda deactivate

cd ../../../
