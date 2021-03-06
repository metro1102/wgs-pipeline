#!/bin/bash

###############################################################################
#                                Initialization                               #
###############################################################################

source config.sh
source functions.sh

###############################################################################
#                              Setup Applications                             #
###############################################################################

infoLog "Installing miniconda 3 ..."
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
bash Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p ${ROOT}/miniconda3
eval "$($ROOT/miniconda3/bin/conda shell.bash hook)"
conda init
conda config --add channels bioconda
conda config --add channels conda-forge
rm Miniconda3-py39_4.9.2-Linux-x86_64.sh

infoLog "Installing qiime2 ..."
wget https://data.qiime2.org/distro/core/qiime2-2021.4-py38-linux-conda.yml
conda create -n qiime2-2021.4 --file qiime2-2021.4-py38-linux-conda.yml
conda deactivate
rm qiime2-2021.4-py38-linux-conda.yml

infoLog "Installing kneaddata + multiqc ..."
conda create -n kneaddata-0.7.4 && conda activate kneaddata-0.7.4
conda install -y kneaddata
conda install -y -c bioconda -c conda-forge multiqc
conda deactivate

infoLog " Installing kraken2 + bracken ..."
conda create -y -n kraken2-2.1.2 && conda activate kraken2-2.1.2
conda install -y kraken2
conda install -y bracken
conda deactivate

infoLog "Installing metaphlan ..."
conda create -y -n metaphlan-3.0.10
conda install metaphlan
conda install -c conda-forge/label/cf202003 tbb
metaphlan --install --bowtiedb ${ROOT}/databases/humann/bowtie2
conda deactivate

infoLog "Installing humann"
conda create -y -n humann
conda install -y -c bioconda humann
conda deactivate

###############################################################################
#                                Setup Adapters                               #
###############################################################################

mkdir ${ROOT}/adapters

cd ${ROOT}/adapters

git clone https://gist.github.com/5cf1d8b071418367d73d768d6549f867.git

cd ~

###############################################################################
#                               Setup Databases                               #
###############################################################################

mkdir ${ROOT}/databases

cd ${ROOT}/databases

initLog "Building kneaddata database(s) ..."
conda activate kneaddata-0.7.4
mkdir kneaddata
cd kneaddata

infoLog "Downloading kneaddata HUMAN REFERENCE database ..."
kneaddata_database --download human_genome bowtie2 human_genome

cd ..
conda deactivate

initLog "Building kraken2 database(s) ..."
conda activate kraken2-2.1.2
mkdir kraken2
cd kraken2

infoLog "Downloading kraken2 NCBI + REFSEQ database ..."
kraken2-build --standard --db ncbi_nucleotide

infoLog "Downloading kraken2 SILVA 16S SSU database ..."
kraken2-build --db silva_16S_SSU --special silva

infoLog "Compiling bracken database(s) via previous downloads ..."
bracken-build -d ncbi_nucleotide -k 35 -l 100
bracken-build -d silva_16S_SSU -k 35 -l 150

cd ..
conda deactivate

initLog "Building humann database(s) ..."
conda activate humann
mkdir humann
cd humann

infoLog "Downloading humann CHOCOPHLAN database ..."
humann_databases --download chocophlan full ${ROOT}/databases

infoLog "Downloading humann UNIREF DIAMOND database ..."
humann_databases --download uniref uniref90_diamond ${ROOT}/databases
mv uniref uniref90_diamond

cd ..
conda deactivate

cd ~

###############################################################################
#                                 Setup Tools                                 #
###############################################################################

mkdir ${ROOT}/scripts

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
