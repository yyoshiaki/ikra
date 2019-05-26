#! /usr/bin/Rscript

library(tximport)
library(readr)
library(stringr)

# Rscript tximport_R.R gencode.vM19.metadata.MGI.gz Illumina_PE_SRR.csv output.tsv

args1 = commandArgs(trailingOnly=TRUE)[1]
args2 = commandArgs(trailingOnly=TRUE)[2]
args3 = commandArgs(trailingOnly=TRUE)[3]

tx2knownGene <- read_delim(args1, '\t', col_names = c('TXNAME', 'GENEID'))
exp.table <- read.csv(args2, row.names=NULL)

files.raw <- exp.table[,2]

# files.raw <- c("SE/test/ttt30.fq.gz", "SE/test/ttt2.fq.gz")

files.raw <- gsub(".gz$", "", files.raw)
files.raw <- gsub(".fastq$", "", files.raw)
files.raw <- gsub(".fq$", "", files.raw)

split.vec <- sapply(files.raw, basename)
# print(paste(c("salmon_output_") , split.vec, c("/quant.sf"), sep=''))

# files <- paste(c("salmon_output_") , exp.table[,2], c("/quant.sf"), sep='')
files <- paste(c("salmon_output_") , split.vec, c("/quant.sf"), sep='')
names(files) <- exp.table$name

#print(files)

# txi.salmon <- tximport(files, type = "salmon", tx2gene = tx2knownGene)
txi.salmon <- tximport(files, type = "salmon", tx2gene = tx2knownGene, countsFromAbundance="scaledTPM")

write.table(txi.salmon$counts, file=args3, sep="\t",col.names=NA,row.names=T,quote=F,append=F)
write.table(exp.table[-c(2,3)], file="designtable.csv",row.names=F,quote=F,append=F)
