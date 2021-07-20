#!/bin/bash

#SBATCH --job-name=trimmomatic
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=5G
#SBATCH --time=48:00:00

# Load source(s)
source "${WGS}/config.sh"
source "${WGS}/functions.sh"

# Initate bash shell using conda
source ~/.bashrc

# Activate kneaddata conda environment
conda activate kneaddata-0.7.4

cd ../../reads/${SAMPLE_TYPE}

# Run trimmomatic on available sequence reads
if [[ $FRAGMENT_TYPE = "paired" ]]; then
  for i in *_R1_*.fastq.gz
  do
      filename=$(basename "$i");
      fname="${filename%%_*.fastq.gz}";
      barcode="$(echo "$filename" | sed -e "s/${fname}_\(.*\)_L.*/\1/")";
      lane="$(echo "$filename" | sed -e "s/${fname}_${barcode}_\(.*\)_R.*/\1/")";
      direction="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_\(.*\)_0.*/\1/")";
      set="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_${direction}_\(.*\).fastq.gz*/\1/")";
      trimmomatic PE -threads 4 -trimlog ${fname}.log \
        ${fname}_${barcode}_${lane}_R1_${set}.fastq.gz ${fname}_${barcode}_${lane}_R2_${set}.fastq.gz \
        ${fname}.trimmed.1.fastq ${fname}.trimmed.2.fastq \
        ${fname}_unmatched_1.fastq ${fname}_unmatched_2.fastq \
        ${TRIMMOMATIC_OPTIONS}
  done
elif [[ $FRAGMENT_TYPE = "single" ]]; then
  for i in *_R1_*.fastq.gz
  do
      filename=$(basename "$i");
      fname="${filename%%_*.fastq.gz}";
      barcode="$(echo "$filename" | sed -e "s/${fname}_\(.*\)_L.*/\1/")";
      lane="$(echo "$filename" | sed -e "s/${fname}_${barcode}_\(.*\)_R.*/\1/")";
      direction="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_\(.*\)_0.*/\1/")";
      set="$(echo "$filename" | sed -e "s/${fname}_${barcode}_${lane}_${direction}_\(.*\).fastq.gz*/\1/")";
      trimmomatic SE -threads 4 -trimlog ${fname}.log \
        ${fname}_${barcode}_${lane}_R1_${set}.fastq.gz \
        ${fname}.trimmed.1.fastq \
        ${fname}_unmatched_1.fastq \
        ${TRIMMOMATIC_OPTIONS}
  done
fi

mv *.fastq ../../${SAMPLE_TYPE}/${ANALYSIS}/results
mv *.log ../../${SAMPLE_TYPE}/${ANALYSIS}/results

cd ../../${SAMPLE_TYPE}/${ANALYSIS}

# Deactivate kneaddata conda environment
conda deactivate

# Clean up file structure
cd results

mkdir trimmomatic
mkdir unmatched
mkdir logs

mv *trimmed* trimmomatic/.
mv *unmatched* unmatched/.
mv *log logs/.

cd trimmomatic

if [ FRAGMENT_TYPE="paired" ]; then

  mkdir ../paired

  for i in *trimmed.1.fastq
  do
    filename=$(basename "$i")
    fname="${filename%%.*.fastq}"
    cp ${filename} ../paired/${fname}_paired_1.fastq
  done

  for i in *trimmed.2.fastq
  do
    filename=$(basename "$i")
    fname="${filename%%.*.fastq}"
    cp ${filename} ../paired/${fname}_paired_2.fastq
  done

  cd ..

elif [ FRAGMENT_TYPE="single"]; then

  mkdir ../single

  for i in *trimmed.1.fastq
  do
    filename=$(basename "$i")
    fname="${filename%%.*.fastq}"
    cp ${filename} ../single/${fname}.fastq
  done

  cd ..

fi

cd ..
