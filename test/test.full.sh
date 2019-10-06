#!/bin/bash

# test modeをつけないバージョン。fasterq-dumpをテストするならこちら。

cd Illumina_SE 

# csv以外を削除
ls | grep -v -E '*.csv' | xargs rm -r

bash ../../ikra.sh Illumina_SE_SRR.csv mouse -t 6

rm -r salmon_*
rm -r multiqc*
rm output.tsv

bash ../../ikra.sh Illumina_SE_fastq.csv mouse --fastq -t 6

cd ../Illumina_PE

# csv以外を削除
ls | grep -v -E '*.csv' | xargs rm -r

bash ../../ikra.sh Illumina_PE_SRR.csv mouse -t 6

rm -r salmon_*
rm -r multiqc*
rm output.tsv

bash ../../ikra.sh Illumina_PE_fastq.csv mouse --fastq -t 6