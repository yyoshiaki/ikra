if [[ ! -f "SRR7501481_1_val_1.fq.gz" ]]; then
  fastq-dump SRR7501481 -X 100000 --gzip  --split-files
fi

if [[ ! -f "gencode.vM19.transcripts.fa.gz" ]]; then
  wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M19/gencode.vM19.transcripts.fa.gz
fi

cwltool ../../basicrnaseq_se.cwl --read1 SRR7501481_1.fastq.gz  --read2 SRR7501481_2.fastq.gz --transcripts gencode.vM19.transcripts.fa.gz
