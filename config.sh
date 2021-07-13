#!/bin/bash

###############################################################################
#                                Configuration                                #
###############################################################################

# General Settings ############################################################

ROOT="/labs/Microbiome/gtesto"      # Root directory for all of your tools..
PROJECTS="/scratch/gtesto/projects" # Projects directory for your projects.
PROJECT_NAME="clinical"             # Project name that you are working on.
SAMPLE_TYPE="saliva"                # Sample type for your working reads.
FRAGMENT_TYPE="paired"              # If reads are "single" or "paired".

PIPELINE="kraken2"                  # Pipeline ("kraken2" or "metaphlan").
ANALYSIS="16S"                      # Analysis ("WGS" or "16S").

# Do NOT include a forward slash at the end of paths when setting directories.

# Database Settings ###########################################################

KNEADDATADB="${ROOT}/databases/kneaddata/human_genome"
KRAKEN2DB="${ROOT}/databases/kraken2/silva_16S_SSU"
BOWTIE2DB="${ROOT}/databases/humann/bowtie2"

# Customization ###############################################################

############################### ! DO NOT EDIT ! ###############################

WGS="${ROOT}/scripts/wgs-pipeline"
ADAPTERS="${ROOT}/adapters/illumina_adapters_DNA.fasta"
TRIMMOMATIC="${ROOT}/miniconda3/envs/kneaddata-0.7.4/share/trimmomatic-0.39-2"

############################### ! DO NOT EDIT ! ###############################

TRIMMMATIC_OPTIONS="ILLUMINACLIP:${ADAPTERS}:2:25:10 SLIDINGWINDOW:4:15 MINLEN:100"

BRACKEN_READ_LEN="100"              # ideal length of reads [default: 100]
