#!/bin/bash

cd Illumina_SE && bash ../../ikra.sh Illumina_SE_SRR.csv mouse --test -t 6

rm -r salmon_*
rm output.tsv

bash ../../ikra.sh Illumina_SE_fastq.csv mouse --fastq -t 6

cd ../Illumina_PE && bash ../../ikra.sh Illumina_PE_SRR.csv mouse --test -t 6

rm -r salmon_*
rm output.tsv

bash ../../ikra.sh Illumina_PE_fastq.csv mouse --fastq -t 6