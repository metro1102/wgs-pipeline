#!/bin/bash

#SBATCH --job-name=wgs-setup
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=120:00:00

###############################################################################
#                                Initialization                               #
###############################################################################

source "./config.sh"
source "./functions.sh"

###############################################################################
#                                Setup Adapters                               #
###############################################################################

mkdir ${ROOT}/adapters

prev_job=$(sbatch --wait -D ${WGS}/setup ${WGS}/setup/install-adapters.sh | sed 's/Submitted batch job //')

###############################################################################
#                              Setup Applications                             #
###############################################################################

mkdir ${ROOT}/databases

#prev_job=$(sbatch --wait -D ${WGS}/setup/ ${WGS}/setup/install-miniconda3.sh | sed 's/Submitted batch job //')
#prev_job=$(sbatch -D ${WGS}/setup/ ${WGS}/setup/install-qiime2.sh | sed 's/Submitted batch job //')
prev_job=$(sbatch -D ${WGS}/setup/ ${WGS}/setup/install-kneaddata.sh | sed 's/Submitted batch job //')
prev_job=$(sbatch -D ${WGS}/setup/ ${WGS}/setup/install-kraken2.sh | sed 's/Submitted batch job //')
prev_job=$(sbatch -D ${WGS}/setup/ ${WGS}/setup/install-humann.sh | sed 's/Submitted batch job //')
prev_job=$(sbatch -D ${WGS}/setup/ ${WGS}/setup/install-krona.sh | sed 's/Submitted batch job //')
prev_job=$(sbatch -D ${WGS}/setup/ ${WGS}/setup/install-biom.sh | sed 's/Submitted batch job //')

###############################################################################
#                                 Setup Scripts                               #
###############################################################################

mkdir ${ROOT}/scripts

prev_job=$(sbatch -D ${WGS}/ ${WGS}/setup/install-scripts.sh | sed 's/Submitted batch job //')
