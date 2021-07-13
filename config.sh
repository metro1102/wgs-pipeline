#!/bin/bash

###############################################################################
#                                Configuration                                #
###############################################################################

# General Settings ############################################################

ROOT=""      # Root directory for all of your tools..
PROJECTS="" # Projects directory for your projects.
PROJECT_NAME=""             # Project name that you are working on.
SAMPLE_TYPE=""                # Sample type for your working reads.
FRAGMENT_TYPE=""              # If reads are "single" or "paired".

PIPELINE=""                  # Pipeline ("kraken2" or "metaphlan").
ANALYSIS=""                      # Analysis ("WGS" or "16S").

# Do NOT include a forward slash at the end of paths when setting directories!

# Database Settings ###########################################################

KNEADDATADB="${ROOT}/databases/kneaddata/"
KRAKEN2DB="${ROOT}/databases/kraken2/"
BOWTIE2DB="${ROOT}/databases/humann/"

# Make sure to ADD the database paths that you wish to use!

# Customization ###############################################################

############################### ! DO NOT EDIT ! ###############################

WGS="${ROOT}/scripts/wgs-pipeline"
ADAPTERS="${ROOT}/adapters/illumina_adapters_DNA.fasta"
TRIMMOMATIC="${ROOT}/miniconda3/envs/kneaddata-0.7.4/share/trimmomatic-0.39-2"

############################### ! DO NOT EDIT ! ###############################

TRIMMOMATIC_OPTIONS="ILLUMINACLIP:${ADAPTERS}:2:25:10 SLIDINGWINDOW:4:15 MINLEN:100"

BRACKEN_READ_LEN="100"              # ideal length of reads [default: 100]
