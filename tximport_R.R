#! /usr/bin/Rscript

library(tximport)
library(readr)

# Rscript tximport_R.R gencode.vM19.metadata.MGI.gz tpTregTconv_rnaseq_experiment_table.csv

args1 = commandArgs(trailingOnly=TRUE)[1]
args2 = commandArgs(trailingOnly=TRUE)[2]

tx2knownGene <- read_delim(args1, '\t', col_names = c('TXNAME', 'GENEID'))
exp.table <- read.csv(args2)

files <- list.files('.',recursive=T, include.dirs=T, pattern='quant.sf')
names(files) <- exp.table$name

# txi.salmon <- tximport(files, type = "salmon", tx2gene = tx2knownGene)
txi.salmon <- tximport(files, type = "salmon", tx2gene = tx2knownGene, countsFromAbundance="scaledTPM")

write.table(txi.salmon$counts, file="counttable.tsv",sep="\t",col.names=NA,row.names=T,quote=F)
write.table(exp.table[-c(2,3,4)], file="designtable.csv",row.names=F,quote=F)