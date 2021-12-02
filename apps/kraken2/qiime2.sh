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

# For kraken results
qiime tools import \
  --input-path ${ANALYSIS}-${SAMPLE_TYPE}-kraken-results.biom \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV100Format \
  --output-path kraken-table.qza

biom convert -i ${ANALYSIS}-${SAMPLE_TYPE}-kraken-results.biom -o kraken-hdf5-table.biom --table-type="OTU table" --to-hdf5

qiime tools import \
  --input-path kraken-hdf5-table.biom \
  --type 'FeatureData[Taxonomy]' \
  --input-format BIOMV210Format \
  --output-path kraken-taxonomy.qza

qiime taxa barplot \
  --i-table kraken-table.qza \
  --i-taxonomy kraken-taxonomy.qza \
  --m-metadata-file ../../../metadata.txt \
  --o-visualization ${ANALYSIS}-${SAMPLE_TYPE}-kraken-taxa-barplot.qzv

# For bracken results
qiime tools import \
  --input-path ${ANALYSIS}-${SAMPLE_TYPE}-bracken-results.biom \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV100Format \
  --output-path bracken-table.qza

biom convert -i ${ANALYSIS}-${SAMPLE_TYPE}-bracken-results.biom -o bracken-hdf5-table.biom --table-type="OTU table" --to-hdf5

qiime tools import \
  --input-path bracken-hdf5-table.biom \
  --type 'FeatureData[Taxonomy]' \
  --input-format BIOMV210Format \
  --output-path bracken-taxonomy.qza

qiime taxa barplot \
  --i-table bracken-table.qza \
  --i-taxonomy bracken-taxonomy.qza \
  --m-metadata-file ../../../metadata.txt \
  --o-visualization ${ANALYSIS}-${SAMPLE_TYPE}-bracken-taxa-barplot.qzv

# Cleanup main directory

mv kraken-table.qza kraken-hdf5-table.biom kraken-taxonomy.qza results/qiime2
mv bracken-table.qza bracken-hdf5-table.biom bracken-taxonomy.qza results/qiime2
