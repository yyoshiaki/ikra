[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4718200.svg)](https://doi.org/10.5281/zenodo.4718200)

# ikra v2.0.1 -RNAseq pipeline centered on Salmon-<img src="img/ikra.png" width="20%" align="right" />

[idep](http://bioinformatics.sdstate.edu/idep/)のinputとして発現量テーブル（gene × sample）をexperiment matrixから自動でつくる。salmonを用いる。

## Usage

```
Usage: ikra.sh experiment_table.csv species \
        [--test, --fastq, --help, --without-docker, --udocker --protein-coding] \
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
  -pc, --protein-coding use protein coding transcripts instead of comprehensive transcripts. (default : True)
  -ct, --comprehensive-transcripts use comprehensive transcripts instead of protein coding transcripts. (default : False)
  -t, --threads
  -o, --output  output file. (default : output.tsv)
  -l, --log  log file. (default : ikra.log)
  -a, --align carry out mapping onto reference genome. hisat2 or star (default : None)
  -g, --gencode specify the version of gencode. (defalut : Mouse=26, Human=37)
  -s1, --suffix_PE_1    suffix for PE fastq files. (default : _1.fastq.gz)
  -s2, --suffix_PE_2    suffix for PE fastq files. (default : _2.fastq.gz)
  -h, --help    Show usage.
  -v, --version Show version.
  -r, --remove-intermediates Remove intermediate files
```

- test optionは各サンプルにおいてリード数を100000に限定する。
- udocker modeはUser権限しか使えないサーバー環境用。詳しくは[https://github.com/indigo-dc/udocker](https://github.com/indigo-dc/udocker)。
- without-docker modeはすべてのツールをインストールした状態で動く。非推奨。
- protein-coding modeはgenesをprotein coding genesのみに限定する。
- threads
- outputはデフォルトでは`output.tsv`。

experiment matrixはカンマ区切りで（csv形式）。

**SRR mode**

|  name  |  SRR |  Layout  | condition1 (optional) | ... |
| ---- | ---- | - | - | - |
|  Treg_LN_1  | SRR5385247 | SE | Treg | ...|
|  Treg_LN_2  |  SRR5385248  | SE  | Treg | ... |

**fastq mode**

|  name  |  fastq(PREFIX) |  Layout  | condition1 (optional) | ... |
| ---- | ---- | - | - | - |
|  Treg_LN_1  | hoge/SRR5385247 | SE | Treg | ...|
|  Treg_LN_2  |  hoge/SRR5385248  | SE  | Treg | ... |

- nameはアンダーバー区切りでcondition、replicateをつなげて書く。
- 前3列は必須。
- 自前のfastq fileを使いたいときは`--fastq`をつける。拡張子は`.fq`, `.fq.gz`, `.fastq`, `fastq.gz`のみに対応。
- fastq fileは`fastq.gz`もしくは`_1.fastq.gz`,`_2.fastq.gz`を除いたpathを。例えば`hoge/SRR5385247.fastq.gz`なら`hoge/SRR5385247`と記載。
- suffixが`_1.fastq.gz`,`_2.fastq.gz`ではない場合は-s1, -s2オプションをつける。
- `../fq/**.fastq.gz`など、実行ディレクトリより上の階層を指定することはdockerの都合上不可能だが、symbolic linkを貼ることで回避できる。
[bonohu blog](https://bonohu.github.io/running-ikra.html)

- Illumina用 : trimmomatic -> trim_galoreに切り替えた。
- Ion S5用: SEしか無い。trimmomaticではなくfastx-toolsを使う。adapterはNoneを入れておく。(test : [DRP003376](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=DRP003376))

### Output

- output.tsv(scaledTPM)

- multiqc_report.html
salmonのマッピング率（トランスクリプトに対するマッピング率）

### 各種仕様

- outputは**scaledTPM** (see. [Soneson, C., Love, M. I. & Robinson, M. D. Differential analyses for RNA-seq: transcript-level estimates improve gene-level inferences. F1000Research 4, 1521 (2015).](https://f1000research.com/articles/4-1521/v2))。
- GCbiasについて、salmonで`--gcBias`を追加した。GCbiasのRNAseqにおける影響に関しては[Mike Love's blog :
RNA-seq fragment sequence bias](https://mikelove.wordpress.com/2016/09/26/rna-seq-fragment-sequence-bias/)。
- validateMappings optionを採用。（alignment-base modeでは使えない。）詳しくは[salmon Frequently Asked Questions](https://combine-lab.github.io/salmon/faq/)。
- humanのリファレンスはGENCODE Release 31 (GRCh38.p12)、mouseのリファレンスはGENCODE Release M22 (GRCm38.p6)です。

## Major bugs that have fixed

### tximport_R.R 2019/04/30 

ikraの`tximport_R.R`にサンプルを取り違えうる重大なバグが見つかり、修正しました。最新版(v1.1.1以降)に更新してお使いください。古いバージョンを使われていた方は、中間ファイルは問題ありませんので、`output.tsv`およびexperiment matrixと同じディレクトリにコピーされている`tximport_R.R`を削除し、もう一度新しいikra.shを実行してください。大変ご迷惑をおかけいたしました。

### fasterq-dump error 2019/09/21

sra-toolsのdocker imageに次のようなエラーがでて処理が止まってしまうバグが報告されました。
`docker: Error response from daemon: OCI runtime create failed: container_linux.go:345: starting container process caused "exec: \"fasterq-dump\": executable file not found in $PATH": unknown.`
最新版では修正されているので、同様のエラーが出る場合は最新版に更新してお使いください。

## Install

dockerかudocker(v1.1.3)をインストール済みであること。
もしくはどちらも使いたくない場合は、すべてのソフトを手動でインストールして、`--without-docker`を用いる。
shell scriptなのでcloneするだけ。

```bash
$ git clone https://github.com/yyoshiaki/ikra.git
```

**SRR modeを使用する際は、 [sra-toolkit](https://github.com/ncbi/sra-tools/wiki)　をローカルに予めインストールしてください。**

## upgrade

```bash
$ git pull origin master
```

## version確認

```bash 
 $ bash ikra.sh --version
 ...
 ikra v2.0.1 -RNAseq pipeline centered on Salmon-
 ...
```

### Version of tools

- sra-tools : 2.10.9
- FastQC : 0.11.9
- MultiQC : 0.10.1
- Trim Galore! : 0.6.7
- Salmon : 1.4.0
- tximport : 1.6.0
- STAR : 2.7.8a
- Hisat2 : 2.2.1
- sambamba : 0.8.0
- deeptools : 3.5.1

### Version of reference genome (alignment optionを使う場合)

- mouse：mm10 (GRCm38)
- human：hg19 (GRCh38)


## test

### SE

**SRR mode**

```bash
$ cd test/Illumina_SE && bash ../../ikra.sh Illumina_SE_SRR.csv mouse --test -t 10
```

**fastq mode**

SRR modeを実行したあとしかできない。（fastqはつけていないから。）

```bash
$ cd test/Illumina_SE && bash ../../ikra.sh Illumina_SE_fastq.csv mouse --fastq -t 10
```

### PE

**SRR mode**

```bash
$ cd test/Illumina_PE && bash ../../ikra.sh Illumina_PE_SRR.csv mouse --test -t 10
```

**fastq mode**

SRR modeを実行したあとしかできない。（fastqはつけていないから。）

```bash
$ cd test/Illumina_PE && bash ../../ikra.sh Illumina_PE_fastq.csv mouse --fastq -t 10
```

#### 開発用

下記を実行できてからcommitすべし。test.full.shはfasterq-dumpをテストするために全リードをダウンロードするため時間がかかる。

```
$ cd test && bash test.sh && bash test.full.sh
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

## Q&A

- iDEPへのエクスポートの際はどのデータタイプを指定すればいいですか？

output.tsvをiDEPで読み込む際は、`Read counts data`にチェックを入れてください。

## やること

[issue](https://github.com/yyoshiaki/auto_counttable_maker/issues)を参照のこと。

## やったこと

詳しくは[Relases](https://github.com/yyoshiaki/ikra/releases)を参照。

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
- protein coding option

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

## Citation

```
Hiraoka, Y., Yamada, K., Yamasaki, R., Kawasaki, Y., Kitabatake, R., Matsumoto, Y., Ishikawa, K., Umezu, Y., Hirose, H., & Yasumizu, Y. (2021). ikra v2.0.1: RNAseq pipeline centered on Salmon. https://doi.org/10.5281/zenodo.4718200
```

## Licence (Updated in Ver. 2.0)

This software is freely available for academic users. Usage for commercial purposes is not allowed. Please refer to the LICENCE page. If you are not an academic user, please contact to the author.

## Contact

Yoshiaki Yasumizu, M.D. [yyasumizu@ifrec.osaka-u.ac.jp](yyasumizu@ifrec.osaka-u.ac.jp)
