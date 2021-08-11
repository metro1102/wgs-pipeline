#!/bin/bash

#SBATCH --job-name=install-qiime2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=16G
#SBATCH --time=72:00:00

# Load source(s)
source "${WGS}/config.sh"
source "${WGS}/functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Create qiime2-2021.4 conda environment
infoLog "Installing qiime2 ..."
wget https://data.qiime2.org/distro/core/qiime2-2021.4-py38-linux-conda.yml
conda env create -n qiime2-2021.4 --file qiime2-2021.4-py38-linux-conda.yml
rm qiime2-2021.4-py38-linux-conda.yml

# Deactivate qiime2-2021.4 conda environment
conda deactivate
