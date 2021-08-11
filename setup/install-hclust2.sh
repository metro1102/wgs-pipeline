#!/bin/bash

#SBATCH --job-name=install-hclust2
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

# Create hclust2 conda environment
conda create -y -n hclust2 && conda activate hclust2

infoLog "Installing hclust2 ..."
conda install -y hclust2

# Deactivate hclust2 conda environment
conda deactivate
