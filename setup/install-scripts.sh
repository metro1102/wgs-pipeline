#!/bin/bash

#SBATCH --job-name=install-scripts
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

cd ${ROOT}/scripts

infoLog "Cloning wgs-pipeline from https://github.com/metro1102/wgs-pipeline.git ..."
git clone https://github.com/metro1102/wgs-pipeline.git

infoLog "Downloading dependencies for wgs-pipeline ..."
cd wgs-pipeline/scripts
mkdir dependencies
cd dependencies

infoLog "Downloading KrakenTools ..."
wget https://github.com/jenniferlu717/KrakenTools/archive/refs/tags/v1.2.tar.gz
tar zxvf v1.2.tar.gz
mv KrakenTools-1.2 KrakenTools

infoLog "Downloading MetaPhlAn/metaphlan2krona.py ..."
wget https://raw.githubusercontent.com/biobakery/MetaPhlAn/master/metaphlan/utils/metaphlan2krona.py
mkdir MetaPhlAn
mv metaphlan2krona.py MetaPhlAn/metaphlan2krona.py

cd ~
