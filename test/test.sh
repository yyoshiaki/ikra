#!/bin/bash

cd Illumina_SE 

ls | grep -v -E '*.csv' | xargs rm -r

bash ../../ikra.sh Illumina_SE_SRR.csv mouse --test -t 6

rm -r salmon_*
rm -r multiqc*
rm output.tsv

bash ../../ikra.sh Illumina_SE_fastq.csv mouse --fastq -t 6

cd ../Illumina_PE

ls | grep -v -E '*.csv' | xargs rm -r

bash ../../ikra.sh Illumina_PE_SRR.csv mouse --test -t 6

rm -r salmon_*
rm -r multiqc*
rm output.tsv

bash ../../ikra.sh Illumina_PE_fastq.csv mouse --fastq -t 6