#!/bin/bash

#SBATCH --job-name=install-krona
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=16G
#SBATCH --time=72:00:00

# Load source(s)
source "../config.sh"
source "../functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Create krona conda environment
conda create -y -n krona && conda activate krona

infoLog "Installing krona ..."
conda install -y -c bioconda krona

# Deactivate krona conda environment
conda deactivate
