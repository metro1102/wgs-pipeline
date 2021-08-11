#!/bin/bash

#SBATCH --job-name=install-adapters
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

cd ${ROOT}/adapters

infoLog "Downloading Illumina Adapters for DNA ..."
wget https://gist.githubusercontent.com/metro1102/5cf1d8b071418367d73d768d6549f867/raw/a7d05437e5aad2419db0554b596c19358e767a68/illumina_adapters_DNA.fastq

cd ~
