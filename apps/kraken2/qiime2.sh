#!/bin/bash

#SBATCH --job-name=qiime2
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

# Activate biom conda environment
conda activate qiime2-2021.4

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${ANALYSIS}

mkdir results/qiime2
mkdir results/qiime2/${DATABASE_NAME}

# Check if a metadata file exists

if [[ ! -f "../../../metadata.txt" ]]; then

  errorLog "No metadata file exist! Skipping qiime2 taxa bar plot(s) generation..."

elif [[ -f "../../../metadata.txt" ]]; then

  # For kraken results (all domains)
  qiime tools import \
    --input-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-results.biom \
    --type 'FeatureTable[Frequency]' \
    --input-format BIOMV100Format \
    --output-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-table.qza

  biom convert -i ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-results.biom -o ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-hdf5-table.biom --table-type="OTU table" --to-hdf5

  qiime tools import \
    --input-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-hdf5-table.biom \
    --type 'FeatureData[Taxonomy]' \
    --input-format BIOMV210Format \
    --output-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxonomy.qza

  qiime taxa barplot \
    --i-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-table.qza \
    --i-taxonomy ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxonomy.qza \
    --m-metadata-file ../../../metadata.txt \
    --o-visualization ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxa-barplot.qzv

  # For kraken results (only bacteria)

  qiime taxa filter-table \
    --i-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-table.qza \
    --i-taxonomy ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxonomy.qza \
    --p-include k__bacteria \
    --o-filtered-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-table-bacteria.qza

  qiime taxa barplot \
    --i-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-table-bacteria.qza \
    --i-taxonomy ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxonomy.qza \
    --m-metadata-file ../../../../metadata.txt \
    --o-visualization ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxa-barplot-bacteria.qzv

  # For bracken results (all domains)
  qiime tools import \
    --input-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-results.biom \
    --type 'FeatureTable[Frequency]' \
    --input-format BIOMV100Format \
    --output-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-table.qza

  biom convert -i ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-results.biom -o ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-hdf5-table.biom --table-type="OTU table" --to-hdf5

  qiime tools import \
    --input-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-hdf5-table.biom \
    --type 'FeatureData[Taxonomy]' \
    --input-format BIOMV210Format \
    --output-path ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxonomy.qza

  qiime taxa barplot \
    --i-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-table.qza \
    --i-taxonomy ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxonomy.qza \
    --m-metadata-file ../../../metadata.txt \
    --o-visualization ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxa-barplot.qzv

  # For bracken results (only bacteria)

  qiime taxa filter-table \
    --i-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-table.qza \
    --i-taxonomy ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxonomy.qza \
    --p-include k__bacteria \
    --o-filtered-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-table-bacteria.qza

  qiime taxa barplot \
    --i-table ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-table-bacteria.qza \
    --i-taxonomy ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxonomy.qza \
    --m-metadata-file ../../../../metadata.txt \
    --o-visualization ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxa-barplot-bacteria.qzv

  # Cleanup main directory

  mv ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-table.qza ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-hdf5-table.biom ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-kraken-taxonomy.qza results/qiime2/${DATABASE_NAME}
  mv ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-table.qza ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-hdf5-table.biom ${ANALYSIS}-${SAMPLE_TYPE}-${DATABASE_NAME}-bracken-taxonomy.qza results/qiime2/${DATABASE_NAME}

fi
