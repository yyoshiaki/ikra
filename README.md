# auto_counttable_maker

[idep](http://bioinformatics.sdstate.edu/idep/)のinputとしてcount tableをexperiment matrix（tpTregTconv_rnaseq_experiment_table.csv）から自動でつくる。salmonを用いる。

## 実行例

```bash
$ bash MakeCountTable_Illumina_SRR.sh experiment_table.csv mouse
```

args
1. experiment matrix(csv)
2. reference(human or mouse)

experiment matrixはカンマ区切りで（csv形式）



|  name  |  SRR or fastq  |  Layout | adapter | condition1 | ... | 
| ---- | ---- | - | - | - | - |
|  Treg_LN_1  | SRR5385247 | SE | TruSeq2-SE.fa | Treg | ...|
|  Treg_LN_2  |  SRR5385248  | SE |TruSeq2-SE.fa | Treg | ... |


nameはアンダーバー区切りでcondition、replicateをつなげて書く。
前3列は必須。

- Illumina用 : adapterは`./adapters`に入っているものを使う。(test : [SRP041655](https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP041655))
- Ion S5用: SEしか無い。trimmomaticではなくfastx-toolsを使う。adapterはNoneを入れておく。(test : [DRP003376](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=DRP003376))

## Install

dockerかudocker(v1.1.3)をインストール済みであること。
もしくは、すべてのソフトを手動でインストールして、MakeCountTable*.shの`RUNINDOCKER=1`に設定する。
shell scriptなのでpathを通すだけ。以下は一例。

```bash
$ git clone https://github.com/yyoshiaki/auto_counttable_maker.git
$ cd auto_counttable_maker
$ echo "export PATH=$PATH:$PWD" >> ~/.bashrc 
$ source ~/.bashrc
```

## test

Illumina

```bash
$ cd test/Illumina && bash ../../MakeCountTable_Illumina_SRR.sh Illumina_SE_SRR.csv mouse
```


Ion (ThermoFisher)

```bash
$ cd test/Ion && bash ../../MakeCountTable_Ion_SRR.sh Ion_SRR.csv mouse
```

## やること

- 各種テスト
- パーミッションを変えないとtrimmomaticで弾かける。

フォルダのパーミッションを777にしてrunした後755にしているが、果たして大丈夫？

## やったこと

- udockerの対応
- 生物種の判別(アナログ)
- gtf, transcript file をGENCODEから
- salmon
- trimmomatic
- tximport
- fastxtools(Ion用)
- trimmomaticのadapterの指定(IonS5をIlluminaに合わせたフォーマットに)
- fastqかSRRの判別(マニュアル)


- 181203 test dirの配置を変更。

## 注意

- MAX_SPOT_IDが0以外の値のときはテストモード（fastq-dumpでダウンロードするread数）
- macbook proはテスト通らなかった（メモリの問題？salmonがおかしい。）

## 参考

- [biocontainers : SNP-calling](http://biocontainers.pro/docs/containers-examples/SNP-Calling/)
- [idep](http://bioinformatics.sdstate.edu/idep/)
- [GENCODE](https://www.gencodegenes.org/)
- [salmon](https://combine-lab.github.io/salmon/getting_started/)
