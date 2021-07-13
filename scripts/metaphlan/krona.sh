#!/bin/bash

#SBATCH --job-name=krona
#SBATCH --mail-user=gtesto@tgen.org
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:05:00

# Load source(s)
source "${WGS}/config.sh"
source "${WGS}/functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate krona conda environment
conda activate krona-2.8

# Create output folders
mkdir reports/krona
mkdir reports/krona/metaphlan

cd reports/metaphlan

# Generate krona using species reports from bracken
python ${WGS}/scripts/dependencies/MetaPhlan/metaphlan2krona.py -r ../metaphlan/merged_abundance_table.txt -o ../krona/metaphlan/merged_abundance_table.krona

ktImportText ../krona/metaphlan/*.krona -o ../krona/metaphlan.krona.html

# Deactivate krona conda environment
conda deactivate

cd ../../
