# auto_counttable_maker

[idep](http://bioinformatics.sdstate.edu/idep/)のinputとしてcount tableをexperiment matrix（tpTregTconv_rnaseq_experiment_table.csv）から自動でつくる。salmonを用いる。

## 実行例

```bash
$ bash MakeCountTable_SRR.sh tpTregTconv_rnaseq_experiment_table.csv human
```

args
1. experiment matrix
2. reference(human or mouse)

## Install

shell scriptなのでpathを通すだけ。以下は一例。

```bash
$ git clone https://github.com/yyoshiaki/auto_counttable_maker.git
$ cd auto_counttable_maker
$ echo "export PATH=$PATH:$PWD" >> ~/.bashrc 
$ source ~/.bashrc
```

## やること

- fastqかSRRの判別
- trimmomatic

## やったこと

- udockerの対応
- 生物種の判別(アナログ)
- gtf, transcript file をGENCODEから
- salmon

## 注意

- MAX_SPOT_IDが0以外の値のときはテストモード（fastq-dumpでダウンロードするread数）
- gtfはidep用にbasic annotationしか使っていない。必要に応じて拡張するべし。

## 参考

- [biocontainers : SNP-calling](http://biocontainers.pro/docs/containers-examples/SNP-Calling/)
- [idep](http://bioinformatics.sdstate.edu/idep/)
- [GENCODE](https://www.gencodegenes.org/)
- [salmon](https://combine-lab.github.io/salmon/getting_started/)
