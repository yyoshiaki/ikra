# ikra v1.1.1 -RNAseq pipeline centered on Salmon-<img src="img/ikra.png" width="20%" align="right" />

[idep](http://bioinformatics.sdstate.edu/idep/)のinputとして発現量テーブル（gene × sample）をexperiment matrixから自動でつくる。salmonを用いる。

## 重要　bugについて　2019/04/30

ikraの`tximport_R.R`にサンプルを取り違えうる重大なバグが見つかり、修正しました。最新版に更新してお使いください。古いバージョンを使われていた方は、中間ファイルは問題ありませんので、`output.tsv`およびexperiment matrixと同じディレクトリにコピーされている`tximport_R.R`を削除し、もう一度新しいikra.shを実行してください。大変ご迷惑をおかけいたしました。

## Usage

```
Usage: ikra.sh experiment_table.csv spiece \
        [--test, --fastq, --help, --without-docker, --udocker] \
        [--threads [VALUE]][--output [VALUE]]\
        [--suffix_PE_1 [VALUE]][--suffix_PE_2 [VALUE]]
  args
    1.experiment matrix(csv)
    2.reference(human or mouse)

Options:
  --test  test mode(MAX_SPOT_ID=100000).(dafault : False)
  --fastq use fastq files instead of SRRid. The extension must be foo.fastq.gz (default : False)
  -u, --udocker
  -w, --without-docker
  -t, --threads
  -o, --output  output file. (default : output.tsv)
  -s1, --suffix_PE_1    suffix for PE fastq files. (default : _1.fastq.gz)
  -s2, --suffix_PE_2    suffix for PE fastq files. (default : _2.fastq.gz)
  -h, --help    Show usage.
```

1. test optionは各サンプルにおいてリード数を100000に限定する。
2. udocker modeはUser権限しか使えないサーバー環境用。詳しくは[https://github.com/indigo-dc/udocker](https://github.com/indigo-dc/udocker)。
3. without-docker modeはすべてのツールをインストールした状態で動く。非推奨。
4. threads
5. outputはデフォルトでは`output.tsv`。

experiment matrixはカンマ区切りで（csv形式）。

**SRR mode**

|  name  |  SRR |  Layout  | condition1 | ... |
| ---- | ---- | - | - | - |
|  Treg_LN_1  | SRR5385247 | SE | Treg | ...|
|  Treg_LN_2  |  SRR5385248  | SE  | Treg | ... |

**fastq mode**

|  name  |  fastq(PREFIX) |  Layout  | condition1 | ... |
| ---- | ---- | - | - | - |
|  Treg_LN_1  | hoge/SRR5385247 | SE | Treg | ...|
|  Treg_LN_2  |  hoge/SRR5385248  | SE  | Treg | ... |

- nameはアンダーバー区切りでcondition、replicateをつなげて書く。
- 前3列は必須。
- 自前のfastq fileを使いたいときは`--fastq`をつける。拡張子は`fastq.gz`のみに対応。
- fastq fileは`fastq.gz`もしくは`_1.fastq.gz`,`_2.fastq.gz`を除いたpathを。例えば`hoge/SRR5385247.fastq.gz`なら`hoge/SRR5385247`と記載。
- suffixが`_1.fastq.gz`,`_2.fastq.gz`ではない場合は-s1, -s2オプションをつける。

- Illumina用 : trimmomatic -> trim_galoreに切り替えた。
- Ion S5用: SEしか無い。trimmomaticではなくfastx-toolsを使う。adapterはNoneを入れておく。(test : [DRP003376](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=DRP003376))

### Output

- output.tsv

- multiqc_report.html
salmonのマッピング率（トランスクリプトに対するマッピング率）

### 仕様について

- outputは**scaledTPM** (see. [Soneson, C., Love, M. I. & Robinson, M. D. Differential analyses for RNA-seq: transcript-level estimates improve gene-level inferences. F1000Research 4, 1521 (2015).](https://f1000research.com/articles/4-1521/v2))。
- GCbiasについて、salmonで`--gcBias`を追加した。GCbiasのRNAseqにおける影響に関しては[Mike Love's blog :
RNA-seq fragment sequence bias](https://mikelove.wordpress.com/2016/09/26/rna-seq-fragment-sequence-bias/)。
- validateMappings optionを採用。（alignment-base modeでは使えない。）詳しくは[salmon Frequently Asked Questions](https://combine-lab.github.io/salmon/faq/)。

## Install

dockerかudocker(v1.1.3)をインストール済みであること。
もしくはどちらも使いたくない場合は、すべてのソフトを手動でインストールして、`--without-docker`を用いる。
shell scriptなのでcloneするだけ。

```bash
$ git clone https://github.com/yyoshiaki/ikra.git
```

## test

### Illumina trim_galore ver.

#### SE

**SRR mode**

```bash
$ cd test/Illumina_SE && bash ../../ikra.sh Illumina_SE_SRR.csv mouse --test -t 10
```

**fastq mode**

SRR modeを実行したあとしかできない。（fastqはつけていないから。）

```bash
$ cd test/Illumina_SE && bash ../../ikra.sh Illumina_SE_fastq.csv mouse --fastq -t 10
```

#### PE

**SRR mode**

```bash
$ cd test/Illumina_PE && bash ../../ikra.sh Illumina_PE_SRR.csv mouse --test -t 50
```

**fastq mode**

SRR modeを実行したあとしかできない。（fastqはつけていないから。）

```bash
$ cd test/Illumina_PE && bash ../../ikra.sh Illumina_PE_fastq.csv mouse --fastq -t 10
```

### Ion (ThermoFisher)

```bash
$ cd test/Ion && bash ../../ikra_Ion_SRR.sh Ion_SRR.csv mouse
```

## Macのひと

salmonがmacで走らない問題だが、[DBCLS大田さん](https://github.com/inutano)に解決していただいた。macではdefaultで2Gbしかメモリをdockerに振っていないことが原因らしい。写真のように、8Gb等大きめのメモリ量を割り振って、Apply & Restartすると解決する。

![img](img/docker_mac0.png)
![img](img/docker_mac1.png)

## ikra pipeline

<img src="img/ikra_pipeline.png"  />

## Tips

SRRデータを探している場合は[http://sra.dbcls.jp/](http://sra.dbcls.jp/index.html)が爆速でおすすめ。

<img src="https://github.com/yyoshiaki/mishima_gassyuku/blob/master/img/dbcls_sra.png?raw=true" width="50%" >

## やること

[issue](https://github.com/yyoshiaki/auto_counttable_maker/issues)を参照のこと。

フォルダのパーミッションを777にしてrunした後755にしているが、果たして大丈夫？

## やったこと

- udockerの対応
- 生物種の判別(アナログ)
- gtf, transcript file をGENCODEから
- salmon
- trimmomatic(legacy)
- trim_galore!
- tximport
- fastxtools(Ion用)
- fastqかSRRの判別(マニュアル)
- salmon gcbias correctionの導入
- salomn validateMappings
- pigz(gzipのマルチスレッド版)
- fasterq-dump
- cwl開発少しだけ
- 名前の変更（ikra）

## legacy

trimmomaticを使ったトリミングを用いたフローは`./legacy`に移動しました。

## 開発戦略

今はまだ完成とは言えないので各自

**"development" branchの中** でFork -> Pull Request。直接masterは変えない。

## 参考

- [biocontainers : SNP-calling](http://biocontainers.pro/docs/containers-examples/SNP-Calling/)
- [idep](http://bioinformatics.sdstate.edu/idep/)
- [GENCODE](https://www.gencodegenes.org/)
- [salmon](https://combine-lab.github.io/salmon/getting_started/)

## cwl版の開発

2019/03/22 https://youtu.be/weJrq5QNt1M cwl作者のMichaelさんの来日配信に合わせてやってみた。
とりあえずPEでtrim_galoreとsalmonをcwl化した。

```
cd test/cwl_PE && bash test.sh
```


## cwl_toolsの由来、参考

- https://github.com/pitagora-galaxy/cwl
- https://github.com/roryk/salmon-cwl
