#! bin/bash

# track log.
# set -xeu

<<COMMENT_OUT

usage

```
$ bash MakCountTable_SRR.sh tpTregTconv_rnaseq_experiment_table.csv examle mm10
```

params.
1. experiment matrix
2. output directly
3. reference

- fastqかSRRの判別
- trimmomatic
- gtf, transcript file をGENCODEから
- salmon
- ignore example
- mkdir for example

COMMENT_OUT

# 実験テーブル.csv
EX_MATRIX_FILE=$1
# dockerを使うときは1.
RUNINDOCKER=1
# number of threads.
THREADS=4
# define programs to run.
PREFETCH=prefetch
PFASTQ_DUMP=pfastq-dump
FASTQ_DUMP=fastq-dump
FASTQC=fastqc
MULTIQC=multiqc
TRIMMOMATIC=trimmomatic
SALMON=salmon

if [[ "$RUNINDOCKER" -eq "1" ]]; then
  echo "RUNNING IN DOCKER"
  DRUN="docker run --rm -v $PWD:/data --workdir /data -i"
  #--user=biodocker

  # set docker images and their version. search docker hub.
  SRA_TOOLKIT_IMAGE=inutano/sra-toolkit
  FASTQC_IMAGE=biocontainers/fastqc:v0.11.5_cv2
  MULTIQC_IMAGE=maxulysse/multiqc
  TRIMMOMATIC_IMAGE=fjukstad/trimmomatic
  SALMON_IMAGE=combinelab/salmon:latest

  docker pull $SRA_TOOLKIT_IMAGE
  docker pull $FASTQC_IMAGE
  docker pull $MULTIQC_IMAGE
  docker pull $TRIMMOMATIC_IMAGE
  docker pull $SALMON_IMAGE

  PREFETCH="$DRUN -v $PWD:/root/ncbi/public/sra $SRA_TOOLKIT_IMAGE $PREFETCH"
  PFASTQ_DUMP="$DRUN $SRA_TOOLKIT_IMAGE $PFASTQ_DUMP"
  FASTQ_DUMP="$DRUN $SRA_TOOLKIT_IMAGE $FASTQ_DUMP"
  FASTQC="$DRUN $FASTQC_IMAGE $FASTQC"
  MULTIQC="$DRUN $MULTIQC_IMAGE $MULTIQC"
  TRIMMOMATIC="$DRUN $TRIMMOMATIC_IMAGE $TRIMMOMATIC"
  SALMON="$DRUN $SALMON_IMAGE $SALMON"
  # docker run --rm -v $PWD:/data -v $PWD:/root/ncbi/public/sra --workdir /data -it inutano/sra-toolkit bash
else
  echo "RUNNING LOCAL"
fi

# 十分大きなものにする。
MAXSIZE=20G
SRA_ROOT=$HOME/ncbi/public/sra

# テスト用。ダウンロードするread数。全部使うときは0に
MAX_SPOT_ID=100000

if [ $MAX_SPOT_ID = 0 ]; then
  MAX_SPOT_ID=""
else
  MAX_SPOT_ID="-X $MAX_SPOT_ID"
fi

echo ${1}
cat $1

# prefetch
# remove first row and extract each row.
for i in `tail -n +2  $1`
do
  name=`echo $i | cut -d, -f1`
  SRR=`echo $i | cut -d, -f2`
  echo "$name $fqfile"
  # prefetch if you do not have SRA or FASTQ files.
  if [[ ! -f "$SRA_ROOT/$SRR.sra" ]] && [[ ! -f "$SRR.fastq" ]]; then
    $PREFETCH $SRR $DATA/--max-size $MAXSIZE
  fi
done


# # pfastq_dump
# for i in `tail -n +2  $1`
# do
# name=`echo $i | cut -d, -f1`
# SRR=`echo $i | cut -d, -f2`
# LAYOUT=`echo $i | cut -d, -f3`

# # SE
# if [ $LAYOUT = SE ]; then

# if [[ ! -f "$SRR.fastq.gz" ]]; then
# $PFASTQ_DUMP --threads $THREADS $SRR.sra
# gzip $SRR.fastq
# fi

# # PE
# else
# if [[ ! -f "$SRR_1.fastq.gz" ]]; then
# $PFASTQ_DUMP --threads $THREADS $SRR.sra --split-files
# gzip $SRR_1.fastq
# gzip $SRR_2.fastq
# fi

# fi
# done

# fastq_dump
# remove first row and extract each row.
<<COMMENT_OUT
for i in `tail -n +2  $1`
do
  # first column
  name=`echo $i | cut -d, -f1`
  # second column
  SRR=`echo $i | cut -d, -f2`
  # third column
  LAYOUT=`echo $i | cut -d, -f3`
  # -d: 区切り文字を指定する
  # -f: 必要な項目を項目数で指定する

  # SE
  if [ $LAYOUT = SE ]; then
    if [[ ! -f "$SRR.fastq.gz" ]]; then
      $FASTQ_DUMP $SRR $MAX_SPOT_ID --gzip
    fi
  # PE
  else
    if [[ ! -f "$SRR_1.fastq.gz" ]]; then
      $FASTQ_DUMP $SRR $MAX_SPOT_ID --gzip --split-files
    fi
  fi
done

# fastqc
for i in `tail -n +2  $1`
do
  name=`echo $i | cut -d, -f1`
  SRR=`echo $i | cut -d, -f2`
  LAYOUT=`echo $i | cut -d, -f3`
  # SE
  if [ $LAYOUT = SE ]; then
    if [[ ! -f "${SRR}_fastqc.zip" ]]; then
    $FASTQC -t $THREADS ${SRR}.fastq.gz
    fi
  # PE
  else
    if [[ ! -f "${SRR}_1_fastqc.zip" ]]; then
    $FASTQC -t $THREADS ${SRR}_1.fastq.gz
    $FASTQC -t $THREADS ${SRR}_2.fastq.gz
    fi
  fi
done


# multiqc
$MULTIQC -n multiqc_report_rawfastq.html .

for i in `tail -n +2 $1`
do
  # SE
  if [ $LAYOUT = SE ]; then
    if [[ ! -f "${SRR}_fastqc.zip" ]]; then
      $FASTQC -t $THREADS ${SRR}.fastq.gz
    fi
  # PE
  else
    if [[ ! -f "${SRR}_1_fastqc.zip" ]]; then
      $FASTQC -t $THREADS ${SRR}_1.fastq.gz
      $FASTQC -t $THREADS ${SRR}_2.fastq.gz
    fi
  fi
done

for i in `tail -n +2  $1`
do
  name=`echo $i | cut -d, -f1`
  SRR=`echo $i | cut -d, -f2`
  LAYOUT=`echo $i | cut -d, -f3`
  # SE
  if [ $LAYOUT = SE ]; then
    if [[ ! -f "${SRR}_fastqc.zip" ]]; then
    $TRIMMOMATIC $LAYOUT -threads $THREADS -phred33 \
    ${SRR}.fastq.gz \
    ${SRR}_after_trim.fastq \
    ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    fi
  # PE
  else
    if [[ ! -f "${SRR}_1_fastqc.zip" ]]; then
    $TRIMMOMATIC $LAYOUT -threads $THREADS -phred33 ${SRR}.fastq.gz ${SRR}_after_trim.fastq \
    $FASTQC -t $THREADS ${SRR}_1.fastq.gz \
    $FASTQC -t $THREADS ${SRR}_2.fastq.gz \
    ${SRR}_paired_output_1.fq \
    ${SRR}_unpaired_output_1.fq \
    ${SRR}_paired_output_2.fq \
    ${SRR}_unpaired_output_2.fq \
    ILLUMINACLIP:adapters.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    fi
  fi
done



COMMENT_OUT
