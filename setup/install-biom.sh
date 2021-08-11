#!/bin/bash

#SBATCH --job-name=install-biom
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

# Create biom conda environment
conda create -y -n biom && conda activate biom

infoLog "Installing biom ..."
conda install -c bioconda kraken-biom

# Deactivate biom conda environment
conda deactivate
