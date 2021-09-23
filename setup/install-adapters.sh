#!/bin/bash

#SBATCH --job-name=install-adapters
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

cd ${ROOT}/adapters

infoLog "Downloading Illumina Adapters for DNA ..."
wget https://gist.githubusercontent.com/metro1102/5cf1d8b071418367d73d768d6549f867/raw/3001deea2366fcef22638f3c4d56f26e6e44cee3/illumina_adapters_DNA.fasta

cd ~
