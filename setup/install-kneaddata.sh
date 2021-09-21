#!/bin/bash

#SBATCH --job-name=install-kneaddata
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

# Create kneaddata conda environment
conda create -y -n kneaddata && conda activate kneaddata

infoLog "Installing kneaddata + multiqc ..."
conda install -y kneaddata
conda install -y -c bioconda -c conda-forge multiqc

initLog "Building kneaddata database(s) ..."
cd ${ROOT}/databases
mkdir kneaddata
cd kneaddata

infoLog "Downloading kneaddata HUMAN REFERENCE database ..."
kneaddata_database --download human_genome bowtie2 human_genome

# Deactivate kneaddata conda environment
conda deactivate

cd ~

