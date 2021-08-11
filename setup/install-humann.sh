#!/bin/bash

#SBATCH --job-name=install-humann
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

# Create humann conda environment
conda create -y -n humann && conda activate humann

infoLog "Installing humann ..."
conda install -y -c bioconda humann

initLog "Building humann database(s) ..."
cd ${ROOT}/databases
mkdir humann
cd humann

infoLog "Downloading metaphlan BOWTIE2 database ..."
metaphlan --install --bowtie2db ${ROOT}/databases/humann/bowtie2

infoLog "Downloading humann CHOCOPHLAN database ..."
humann_databases --download chocophlan full ${ROOT}/databases

infoLog "Downloading humann UNIREF DIAMOND database ..."
humann_databases --download uniref uniref90_diamond ${ROOT}/databases
mv uniref uniref90_diamond

# Deactivate humann conda environment
conda deactivate

cd ~

