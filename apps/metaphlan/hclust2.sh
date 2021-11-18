#!/bin/bash

#SBATCH --job-name=hclust2
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2G
#SBATCH --time=00:05:00

# Load source(s)
source "../../config.sh"
source "../../functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate hclust2 conda environment
conda activate hclust2

cd ${PROJECTS}/${PROJECT_NAME}/${SAMPLE_TYPE}/${PIPELINE}/${ANALYSIS}

# Run hclust2 on metaphlan results
hclust2.py -i ${SAMPLE_TYPE}-metaphlan-results.txt -o reports/metaphlan/abundance_heatmap_species.png --ftop 25 --f_dist_f braycurtis --s_dist_f braycurtis --cell_aspect_ratio 0.5 -l --flabel_size 6 --slabel_size 6 --max_flabel_len 100 --max_slabel_len 100 --minv 0.1 --dpi 300

# Deactivate hclust2 conda environment
conda deactivate
