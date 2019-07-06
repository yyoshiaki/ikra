# ikra v1.2.0 -RNAseq pipeline centered on Salmon-<img src="img/ikra.png" width="20%" align="right" />


An expression amount table (gene × sample) is automatically created from the experiment matrix as an input of [idep](http://bioinformatics.sdstate.edu/idep/). This tool uses [salmon](https://combine-lab.github.io/salmon/).

## Important　about bug　2019/04/30

A serious bug has been found and fixed that could misinterpret a sample in the `tximport_R.R` of ikra. Please update it to the latest version. If you are using the old version, there is no problem with the intermediate file, so delete `tximport_R.R` copied to the same directory as `output.tsv` and experiment matrix, and execute new ikra.sh again, please. We apologize for the inconvenience.

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
  -pc, --protein-coding use protein coding transcripts instead of comprehensive transcripts.
  -t, --threads
  -o, --output  output file. (default : output.tsv)
  -s1, --suffix_PE_1    suffix for PE fastq files. (default : _1.fastq.gz)
  -s2, --suffix_PE_2    suffix for PE fastq files. (default : _2.fastq.gz)
  -h, --help    Show usage.
  -v, --version Show version.
```

- **test option** limits the number of reads to 100,000 in each sample.
- **udocker mode** is for server environments that can only use User privileges. For more information [https://github.com/indigo-dc/udocker](https://github.com/indigo-dc/udocker).
- **without-docker mode** works with all tools installed. Not recommended.
- **protein-coding mode** restricts genes to protein coding genes only.
- **threads**
- **output** is `output.tsv` by default.  
**experiment matrix** is separated by commas (csv format).

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

- name is written by connecting condition and replicate with underbars.
- The first three columns are required.
- If you want to use your own fastq file, add `--fastq`. The extension supports only `.fq`, `.fq.gz`, `.fastq` and `fastq.gz`.
- fastq file specifies path excluding `fastq.gz` or` _1.fastq.gz` and `_2.fastq.gz`. For example, `hoge/SRR5385247.fastq.gz` is described as `hoge/SRR5385247`.
- If suffix is not `_1.fastq.gz` or `_2.fastq.gz`, add -s1 and -s2 options.
- It is impossible for docker to specify a hierarchy above the execution directory, such as `../fq/**.fastq.gz`, but it can be avoided by pasting a symbolic link.
[bonohu blog](https://bonohu.github.io/running-ikra.html)

- For Illumina : switched to trimmomatic-> trim_galore.
- For Ion S5 : Only for SE. Use fastx-tools instead of trimmomatic. The adapter contains None.(test : [DRP003376](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=DRP003376))

### Output

- output.tsv(scaledTPM)

- multiqc_report.html  
mapping rate of salmon(mapping rate for transcript)

### Various Specifications

- output is **scaledTPM** (see. [Soneson, C., Love, M. I. & Robinson, M. D. Differential analyses for RNA-seq: transcript-level estimates improve gene-level inferences. F1000Research 4, 1521 (2015).](https://f1000research.com/articles/4-1521/v2))。
- About GCbias   `—-gcbias` is added on salmon. You can refer to https://mikelove.wordpress.com/2016/09/26/rna-seq-fragment-sequence-bias/ about the influence on RNAseq by GCbias.
- ValidateMappings option was adopted. (You can’t use it while using alignment-base mode.) Please see https://combine-lab.github.io/salmon/faq/ for further details.


## Important  About a Bug  2019/04/30

A serious bug has been found and fixed that could misinterpret a sample in the `tximport_R.R` of ikra. Please update it to the latest version. If you are using the old version, there is no problem with the intermediate file, so delete `tximport_R.R` copied to the same directory as `output.tsv` and experiment matrix, and execute new ikra.sh again, please. We apologize for the inconvenience.

## Install

You need to install docker or udocker(v1.1.3).
If you don’t want to use both of them, you must install all softwares by yourself and use `—-without-docker`.
It’s a shell script, so you have only to clone it.

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

You can execute it after you execute SRR mode. (That is because you don’t have fastq file.)

```bash
$ cd test/Illumina_SE && bash ../../ikra.sh Illumina_SE_fastq.csv mouse --fastq -t 10
```

#### PE

**SRR mode**

```bash
$ cd test/Illumina_PE && bash ../../ikra.sh Illumina_PE_SRR.csv mouse --test -t 10
```

**fastq mode**

You can execute it after you execute SRR mode. (That is because you don’t have fastq file.)


```bash
$ cd test/Illumina_PE && bash ../../ikra.sh Illumina_PE_fastq.csv mouse --fastq -t 10
```

### Ion (ThermoFisher)

```bash
$ cd test/Ion && bash ../../ikra_Ion_SRR.sh Ion_SRR.csv mouse
```

## For Mac Users

[DBCLS Mr.Ota](https://github.com/inutano) solved the problem that salmon doesn’t work on Mac. The cause of the problem is that Docker is allocated only 2GB by default on Mac. Therefore,like this picture, the problem will be solved by allocating large amount of memories to Docker, such as 8GB, and doing Apply & Restart.

![img](img/docker_mac0.png)
![img](img/docker_mac1.png)

## ikra pipeline

<img src="img/ikra_pipeline.png"  />

## Tips

You can find SRR data so quickly in [http://sra.dbcls.jp/](http://sra.dbcls.jp/index.html)

<img src="https://github.com/yyoshiaki/mishima_gassyuku/blob/master/img/dbcls_sra.png?raw=true" width="50%" >

## Issue

Please refer to [issue](https://github.com/yyoshiaki/ikra/issues)

## Releases

Please refer to [Relases](https://github.com/yyoshiaki/ikra/releases)

- add support for udocker
- add setting of species
- gtf and transcript file from GENCODE
- salmon
- trimmomatic(legacy)
- trim_galore!
- tximport
- fastxtools(for Ion)
- judging fastq or SRR(manual)
- introduce "salmon gcbias correction"
- salomn validateMappings
- pigz(multithread version of gzip)
- fasterq-dump
- cwl development is in progress
- rename to "ikra"
- protein coding option

## Legacy

Move program flow used trimming by trimmomatic to `./legacy`

## Development Strategy

Still hasn't been complicated.

Fork -> Pull Request in **in "development" branch.** Don't change "master" directly.

##  Reference

- [biocontainers : SNP-calling](http://biocontainers.pro/docs/containers-examples/SNP-Calling/)
- [idep](http://bioinformatics.sdstate.edu/idep/)
- [GENCODE](https://www.gencodegenes.org/)
- [salmon](https://combine-lab.github.io/salmon/getting_started/)

## Development of cwl ver.

2019/03/22 https://youtu.be/weJrq5QNt1M We tried developing it because Mr.Michael would come into Japan.  
For now, cwlnized trim_galore and salmon in PE.

```
cd test/cwl_PE && bash test.sh
```

## sorce and reference ー cwl_tools

- https://github.com/pitagora-galaxy/cwl
- https://github.com/roryk/salmon-cwl
