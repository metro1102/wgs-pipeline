#!/bin/bash
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gtesto@tgen.org
#SBATCH --job-name=shotgun
#SBATCH --cpus-per-task=8
#SBATCH --time=72:00:00
#SBATCH --mem=80G

###############################################################################
#                                    Setup                                    #
###############################################################################

# Please configure the following settings:
ROOT="/scratch/gtesto/projects/" # Enter the root directory for your projects.
PROJECT_NAME="clinical" # Enter the project name that you are working on.
SAMPLE_TYPE="saliva" # Enter the sample type for your working reads.
FRAGMENT_TYPE="paired" # Enter reads are "single" or "paired".
PIPELINE="kraken2" # Enter your desired pipeline ("kraken2" or "metaphlan").

# If using kraken2, please specify the database path to use.
DATABASE="/labs/Microbiome/gtesto/databases/silva_138.1_SSU"


###################### ! DO NOT EDIT BEYOND THIS POINT ! ######################


###############################################################################
#                                Initalization                                #
###############################################################################

# Initate bash shell using conda
source ~/.bashrc

# Navigate to project and samples folder
cd ${ROOT}${PROJECT_NAME}

mkdir ${SAMPLE_TYPE} && cd ${SAMPLE_TYPE}

###############################################################################
#                             Specific Conditions                             #
###############################################################################

# FRAGMENT_TYPE
if [ FRAGMENT_TYPE="paired" ] || [ FRAGMENT_TYPE="single"]; then

  echo "Running sequence read(s) in ${FRAGMENT_TYPE} end mode..."

elif [ -z "$FRAGMENT_TYPE" ]; then

  echo "Please specify the type of reads that you have ['paired' or 'single']!"

  scancel $SLURM_JOBID

fi

# PIPELINE
if [ PIPELINE="kraken2" ] || [ PIPELINE="metaphlan" ]; then

  echo "Running the ${PIPELINE} workflow..."

  # If using kraken2, verify if provided a database path

  if [ PIPELINE="kraken2" ] || [ -z "$DATABASE" ]; then

    echo "Please set a desired kraken2 database ['standard' or 'silva']!"

    scancel $SLURM_JOBID

  fi

elif [ -z "$PIPELINE" ]; then

  echo "Please set a desired pipeline ['kraken2' or 'metaphlan']!"

  scancel $SLURM_JOBID

fi

###############################################################################
#                                Run Kneaddata                                #
###############################################################################

# Activate kneaddata conda environment
conda activate kneaddata-0.7.4

# Create output folder
mkdir results
mkdir results/kneaddata

cd ../reads/${SAMPLE_TYPE}

# Run kneaddata on available sequence reads
if [ FRAGMENT_TYPE="paired" ]; then
  for i in *_R1_*.fastq.gz
  do
      filename=$(basename "$i");
      fname="${filename%%_*.fastq.gz}";
      barcode="$(echo "$filename" | sed -e "s/${fname}_\(.*\)_L.*/\1/")";
      lane="$(echo "$filename" | sed -e "s/${fname}_${barcode}_\(.*\)_R.*/\1/")";
      direction="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_\(.*\)_0.*/\1/")";
      set="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_${direction}_\(.*\).fastq.gz*/\1/")";
      kneaddata \
        --input ${fname}_${barcode}_${lane}_R1_${set}.fastq.gz \
        --input ${fname}_${barcode}_${lane}_R2_${set}.fastq.gz \
        --trimmomatic /labs/Microbiome/gtesto/miniconda3/envs/kneaddata-0.7.4/share/trimmomatic-0.39-2 \
        --trimmomatic-options="ILLUMINACLIP:/scratch/gtesto/adapters/illumina_adapters_DNA.fasta:2:25:10 SLIDINGWINDOW:4:15 MINLEN:100" \
        --reference-db /labs/Microbiome/gtesto/databases/human_genome \
        --max-memory 40g -p 8 -t 8 --output-prefix ${fname} \
        --output ${ROOT}${PROJECT_NAME}/${SAMPLE_TYPE}/results
  done
elif [ FRAGMENT_TYPE="single"]; then
  for i in *_R1_*.fastq.gz
  do
    filename=$(basename "$i")
    fname="${filename%%_*.fastq.gz}"
    barcode="$(echo "$filename" | sed -e "s/${fname}_\(.*\)_L.*/\1/")";
    lane="$(echo "$filename" | sed -e "s/${fname}_${barcode}_\(.*\)_R.*/\1/")";
    direction="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_\(.*\)_0.*/\1/")";
    set="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_${direction}_\(.*\).fastq.gz*/\1/")";
    kneaddata \
      --input ${fname}_${barcode}_${lane}_R1_${set}.fastq.gz \
        --trimmomatic-options="ILLUMINACLIP:/scratch/gtesto/adapters/illumina_adapters_DNA.fasta:2:25:10 SLIDINGWINDOW:4:15 MINLEN:100" \
        --reference-db /labs/Microbiome/gtesto/databases/human_genome \
        --max-memory 40g -p 8 -t 8 --output-prefix ${fname} \
        --output ${ROOT}${PROJECT_NAME}/${SAMPLE_TYPE}/results
  done
fi

cd ../../${SAMPLE_TYPE}

# Output kneaddata report
kneaddata_read_count_table \
  --input results \
  --output reports/kneaddata/reads_report.kneaddata

# Deactivate kneadddata conda environment
conda deactivate

# Clean up file structure
cd results

if [ FRAGMENT_TYPE="paired" ]; then

  mkdir paired
  mv *paired* paired/.

elif [ FRAGMENT_TYPE="single"]; then

  mkdir single
  mv *.fastq single/

fi

mkdir homo_sapien
mkdir trimmomatic
mkdir unmatched
mkdir logs

mv *Homo_sapiens* homo_sapien/.
mv *trimmed* trimmomatic/.
mv *unmatched* unmatched/.
mv *log logs/.

cd ..

###############################################################################
#                               Quality Control                               #
###############################################################################

# Activate QC conda environment
conda activate kneaddata-0.7.4

# Create output folders
mkdir reports/fastqc/after_trimming
mkdir reports/multiqc/after_trimming

# Run quality control check on trimmed sequence reads
fastqc -t 8 results/paired/*.fastq --outdir=reports/fastqc/after_trimming
multiqc reports/fastqc/after_trimming --outdir=reports/multiqc/after_trimming

# Deactivate QC conda environment
conda deactivate

###############################################################################
#                              Pipeline Script(s)                             #
###############################################################################

if [ PIPELINE="kraken2" ]; then

 ###############################################################################
 #                                 Run kraken2                                 #
 ###############################################################################

 # Activate kraken2 conda environment
 conda activate kraken2-2.1.2

 # Create output folders
 mkdir reports/kraken2
 mkdir results/kraken2

 # Run kraken2 on available reads
 if [ FRAGMENT_TYPE="paired" ]; then

 for i in results/paired/*_paired_1.fastq;
 do
   filename=$(basename "$i");
   fname="${filename%_paired_*.fastq}";
   kraken2 --db ${DATABASE} --threads 8 --use-names --output results/kraken2/${fname}_output.kraken --report reports/kraken2/${fname}_report.kraken --paired results/paired/${fname}_paired_1.fastq results/paired/${fname}_paired_2.fastq
 done

 elif [ FRAGMENT_TYPE="single" ]; then

 for i in results/single/*.fastq
 do
   filename=$(basename "$i");
   fname="${filename%*.fastq}";
   kraken2 --db ${DATABASE} --threads 8 --use-names --output results/kraken2/${fname}_output.kraken --report reports/kraken2/${fname}_report.kraken results/single/${fname}.fastq
 done

 fi

 # Deactivate kraken2 conda environment
 conda deactivate

 #############################################################################
 #                                Run bracken                                #
 #############################################################################

 conda activate kraken2-2.1.2

 mkdir results/kraken2/bracken
 mkdir reports/kraken2/bracken

 cd reports/kraken2

 for i in *_report.kraken;
 do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   bracken -d /labs/Microbiome/gtesto/databases/all_nucleotide -l S -i $i -o bracken/${fname}_species_output.bracken -w bracken/${fname}_species_report.bracken;
 done

 for i in *_report.kraken;
 do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   bracken -d /labs/Microbiome/gtesto/databases/all_nucleotide -l G -i $i -o bracken/${fname}_genus_output.bracken -w bracken/${fname}_genus_report.bracken;
 done

 for i in *_report.kraken;
 do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   bracken -d /labs/Microbiome/gtesto/databases/all_nucleotide -l P -i $i -o bracken/${fname}_phylum_output.bracken -w bracken/${fname}_phylum_report.bracken;
 done

 # This step is necessary, and we should combine outputs from kraken2 & bracken
 # Because reads shouldn't be combined before processing, this step is important
 combine_bracken_outputs.py --files bracken/*species.bracken -o bracken/all_species_output.bracken
 combine_bracken_outputs.py --files bracken/*genus.bracken -o bracken/all_genus_output.bracken
 combine_bracken_outputs.py --files bracken/*phylum.bracken -o bracken/all_phylum_output.bracken

 mv *_output.bracken ../../../results/kraken2/bracken
 mv *all* ../../../results/kraken2/bracken

 # Deactivate kraken2 conda environment
 conda deactivate

 cd ../../../

 ###############################################################################
 #                                  Run krona                                  #
 ###############################################################################

 # Activate krona conda environment
 conda activate krona-2.8

 # Create output folders
 mkdir reports/krona
 mkdir reports/krona/kraken2
 mkdir reports/krona/bracken

 cd reports/kraken2

 # Generate krona using species reports from bracken
 for i in *_report.kraken;
 do
   filename=$(basename "$i");
   fname="${filename%_report.kraken}";
   python /labs/Microbiome/gtesto/scripts/KrakenTools-1.2/kreport2krona.py -r ${filename} -o ../krona/kraken2/${fname}.krona;
 done

 ktImportText ../krona/kraken2/*.krona -o ../krona/kraken2.krona.html

 cd bracken
 for i in *_species_report.bracken;
 do
   filename=$(basename "$i")
   fname="${filename%_species_report.bracken}";
   python /labs/Microbiome/gtesto/scripts/KrakenTools-1.2/kreport2krona.py -r ${filename} -o ../../krona/bracken/${fname}.krona;
 done

 ktImportText ../../krona/bracken/*.krona -o ../../krona/bracken.krona.html

 # Deactivate krona conda environment
 conda deactivate

 cd ../../../

 ###############################################################################
 #                                   Run biom                                  #
 ###############################################################################

 # Activate biom conda environment
 conda activate kraken-biom-1.0.1

 cd reports/kraken2/bracken

 # Temporarily copy & rename bracken species reports
 mkdir temp

 for i in *_species_report.bracken
 do
   filename=$(basename "$i")
   fname="${filename%_species_report.bracken}";
   cp ${filename} temp/${fname}.bracken
 done

 cd temp

 # Generate biom format & summarize the results
 kraken-biom *.bracken -o sequences.biom --fmt json
 biom summarize-table -i sequences.biom -o sequences-summary.txt

 # Deactivate biom conda environment
 conda deactivate

 # Move biom files back to the main directory
 mv sequences.biom ../../../../
 mv sequences-summary.txt ../../../../

 # Remove temporary folder
 cd .. && rm -r temp

 cd ../../../

 # Rename biom files to sample type
 #mkdir results/biom
 mv sequences.biom ${SAMPLE_TYPE}-bracken-results.biom
 mv sequences-summary.txt ${SAMPLE_TYPE}-bracken-summary.txt

elif [ PIPELINE="metaphlan" ]; then

 ###############################################################################
 #                                Run metaphlan                                #
 ###############################################################################

 # Activate metaphlan conda environment
 conda activate metaphlan-3.0.10

 # Create output folders
 mkdir results/bowtie2
 mkdir reports/metaphlan

 # Run metaphlan on available trims
 for i in results/paired/*_paired_1.fastq
 do
   filename=$(basename "$i")
   fname="${filename%_paired_*.fastq}";
   metaphlan --bowtie2db /labs/Microbiome/gtesto/databases/bowtie2 results/paired/${fname}_paired_1.fastq,results/paired/${fname}_paired_2.fastq --input_type fastq --bowtie2out results/bowtie2/${fname}.bowtie2.bz2 -o reports/metaphlan/${fname}.txt
 done

 cd reports/metaphlan

 merge_metaphlan_tables.py * > merged_abundance_table.txt

 grep -E "s__|clade" merged_abundance_table.txt | sed 's/^.*s__//g'\
   | cut -f1,3-8 | sed -e 's/clade_name/SampleID/g' > merged_abundance_table_species.txt

 # Move & rename merged_abundance_table_species
 mv merged_abundance_table_species.txt ../../${SAMPLE_TYPE}-metaphlan-results.txt

 # Deactivate metaphlan conda environment
 conda deactivate

 cd ../../

 ###############################################################################
 #                                  Run krona                                  #
 ###############################################################################

 # Activate krona conda environment
 conda activate krona-2.8

 # Create output folders
 mkdir reports/krona
 mkdir reports/krona/metaphlan

 cd reports/metaphlan

 # Generate krona using species reports from bracken
 python /labs/Microbiome/gtesto/scripts/metaphlan2krona.py -r ../metaphlan/merged_abundance_table.txt -o ../krona/metaphlan/merged_abundance_table.krona

 ktImportText ../krona/metaphlan/*.krona -o ../krona/metaphlan.krona.html

 # Deactivate krona conda environment
 conda deactivate

 cd ../../

 ###############################################################################
 #                                 Run hclust2                                 #
 ###############################################################################

 # Activate hclust2 conda environment
 conda activate hclust2

 # Run hclust2 on metaphlan results
 hclust2.py -i ${SAMPLE_TYPE}-metaphlan-results.txt -o reports/metaphlan/abundance_heatmap_species.png --ftop 25 --f_dist_f braycurtis --s_dist_f braycurtis --cell_aspect_ratio 0.5 -l --flabel_size 6 --slabel_size 6 --max_flabel_len 100 --max_slabel_len 100 --minv 0.1 --dpi 300

 # Deactivate hclust2 conda environment
 conda deactivate

fi

################
## RUN HUMAN2 ##
################

# cd results/paired

# mkdir output_cat

# for name in *_paired_1.fastq
# do
#     other="${name/_paired_1/_paired_2}"
#     cat "$name" "$other" > output_cat/"$name"
# done

# cd output_cat

# for i in *.fastq
# do
#     humann2 --input $i \
#         --output text \

# done
