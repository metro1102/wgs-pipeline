#!/bin/bash

#SBATCH --job-name=install-miniconda3
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

infoLog "Installing miniconda 3 ..."
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh
bash Miniconda3-py39_4.10.3-Linux-x86_64.sh -b -p ${ROOT}/miniconda3
eval "$($ROOT/miniconda3/bin/conda shell.bash hook)"
conda init
conda config --add channels bioconda
conda config --add channels conda-forge
rm Miniconda3-py39_4.10.3-Linux-x86_64.sh
