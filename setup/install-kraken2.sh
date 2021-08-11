#!/bin/bash

#SBATCH --job-name=install-kraken2
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

# Create kraken2 conda environment
conda create -y -n kraken2 && conda activate kraken2

infoLog " Installing kraken2 + bracken ..."
conda install -y kraken2
conda install -y bracken

initLog "Building kraken2 database(s) ..."
cd ${ROOT}/databases
mkdir kraken2
cd kraken2

infoLog "Downloading kraken2 NCBI + REFSEQ database ..."
kraken2-build --standard --db ncbi_nucleotide

infoLog "Downloading kraken2 SILVA 16S SSU database ..."
kraken2-build --db silva_16S_SSU --special silva

infoLog "Compiling bracken database(s) via previous downloads ..."
bracken-build -d ncbi_nucleotide -k 35 -l 100
bracken-build -d silva_16S_SSU -k 35 -l 150

# Deactivate kraken2 conda environment
conda deactivate

cd ~
