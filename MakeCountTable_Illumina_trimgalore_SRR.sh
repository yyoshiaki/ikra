#! bin/bash
set -xeu

<<COMMENTOUT


COMMENTOUT

#　オプション関連ここから
#　大部分は http://dojineko.hateblo.jp/entry/2016/06/30/225113 から引用させていただきました。

#　変数 EX_MATRIX_FILE, REF_SPIECE はここで定義
#　if [[ $IF_TEST = true ]]; then でテストモード用の実行が可能

#　今まで$1 = EX_MATRIX_FILEだったのを変更している
#　以降の$1をEX_MATRIX_FILEで置き換える必要がある？(必要なら修正お願いします...)

set +u

PROGNAME="$( basename $0 )"

# Usage
function usage() {
  cat << EOS >&2
Usage: ${PROGNAME} experiment_table.csv spiece [--test, --help, --without-docker, --udocker] [--threads [VALUE]]
  args
    1.experiment matrix(csv)
    2.reference(human or mouse)

Options:
  --test  test mode(MAX_SPOT_ID=100000).(dafault : False)
  --fastq use fastq files instead of SRRid. The extension must be foo.fastq.gz (default : False)
  -u, --udocker
  -w, --without-docker
  -t, --threads
  -h, --help    Show usage.
EOS
  exit 1
}

# デフォルト値を先に定義しておく
RUNINDOCKER=1
DOCKER=docker
THREADS=1
IF_TEST=false
IF_FASTQ=false

# オプションをパース
PARAM=()
for opt in "$@"; do
    case "${opt}" in
        #　モード選択など引数の無いオプションの場合
        '--test' )
            IF_TEST=true; shift
            ;;
        '--fastq' )
            IF_FASTQ=true; shift
            ;;
        '-u'|'--undocker' )
            DOCKER=udocker; shift
            ;;
        '-w'|'--without-docker' )
            RUNINDOCKER=0; shift
            ;;
        #　引数が任意の場合
        '-t'|'--threads' )
            THREADS=4; shift
            if [[ -n "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                THREADS="$1"; shift
            fi
            ;;
        '-h' | '--help' )
            usage
            ;;
        '--' | '-' )
            shift
            PARAM+=( "$@" )
            break
            ;;
        -* )
            echo "${PROGNAME}: illegal option -- '$( echo $1 | sed 's/^-*//' )'" 1>&2
            exit 1
            ;;
        * )
            if [[ -n "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                PARAM+=( "$1" ); shift
            fi
            ;;
    esac
done

# オプション無しの値を使う場合はここで処理する
EX_MATRIX_FILE="${PARAM}"; PARAM=("${PARAM[@]:1}")
REF_SPIECE="${PARAM}"; PARAM=("${PARAM[@]:1}")

[[ -z "${EX_MATRIX_FILE}" ]] && usage
[[ -z "${REF_SPIECE}" ]] && usage

# 規定外のオプションがある場合にはusageを表示
if [[ -n "${PARAM[@]}" ]]; then
    usage
fi

# 結果を表示(オプションテスト用)
cat << EOS | column -t
EX_MATRIX_FILE ${EX_MATRIX_FILE}
REF_SPIECE ${REF_SPIECE}
RUNINDOCKER ${RUNINDOCKER}
DOCKER ${DOCKER}
THREADS ${THREADS}
IF_TEST ${IF_TEST:-false}
IF_FASTQ ${IF_FASTQ:-false}
EOS

set -u

#　オプション関連ここまで

# 実験テーブル.csv

# 十分大きなものにする。
MAXSIZE=20G
SRA_ROOT=$HOME/ncbi/public/sra

SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [[ $REF_SPIECE = mouse ]]; then
  BASE_REF_TRANSCRIPT=ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M19
  REF_TRANSCRIPT=gencode.vM19.transcripts.fa.gz
  SALMON_INDEX=salmon_index_mouse
#   REF_GTF=gencode.vM19.annotation.gtf.gz
  TX2SYMBOL=gencode.vM19.metadata.MGI.gz

elif [[ $REF_SPIECE = human ]]; then
  BASE_REF_TRANSCRIPT=ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29
  # REF_TRANSCRIPT=gencode.v29.pc_translations.fa.gz
  REF_TRANSCRIPT=gencode.v29.transcripts.fa.gz
  SALMON_INDEX=salmon_index_human
#   REF_GTF=gencode.v29.annotation.gtf.gz
  TX2SYMBOL=gencode.v29.metadata.HGNC.gz

else
  echo No reference speice!
  exit
fi

COWSAY=cowsay
PREFETCH=prefetch
PFASTQ_DUMP=pfastq-dump
FASTQ_DUMP=fastq-dump
FASTERQ_DUMP=fasterq-dump
FASTQC=fastqc
MULTIQC=multiqc
# TRIMMOMATIC=trimmomatic
TRIMGALORE=trim_galore
SALMON=salmon
RSCRIPT_TXIMPORT=Rscript
WGET=wget
PIGZ=pigz


if [[ "$RUNINDOCKER" -eq "1" ]]; then
  echo "RUNNING IN DOCKER"
  # docker を走らせ終わったらコンテナを削除。(-rm)ホストディレクトリをコンテナにマウントする。(-v)

  DRUN="$DOCKER run -u `id -u $USER` --rm -v $PWD:/home --workdir /home "

  SCRIPT_DIR=`dirname "$0"`
  #--user=biodocker

  # 危険！
  # chmod 777 .

  COWSAY_IMAGE=docker/whalesay
  SRA_TOOLKIT_IMAGE=inutano/sra-toolkit
  FASTQC_IMAGE=biocontainers/fastqc:v0.11.5_cv2
  MULTIQC_IMAGE=maxulysse/multiqc
#   TRIMMOMATIC_IMAGE=fjukstad/trimmomatic
#   TRIMMOMATIC_IMAGR=comics/trimmomatic
  TRIMGALORE_IMAGE=miasteinberg/trim-galore
  SALMON_IMAGE=combinelab/salmon:latest
#   SALMON_IMAGE=fjukstad/salmon
  RSCRIPT_TXIMPORT_IMAGE=fjukstad/tximport
  WGET_IMAGE=fjukstad/tximport
  PIGZ_IMAGE=genevera/docker-pigz

  $DOCKER pull $COWSAY_IMAGE
  $DOCKER pull $SRA_TOOLKIT_IMAGE
  $DOCKER pull $FASTQC_IMAGE
  $DOCKER pull $MULTIQC_IMAGE
  # $DOCKER pull $TRIMMOMATIC_IMAGE
  $DOCKER pull $TRIMGALORE_IMAGE
  $DOCKER pull $SALMON_IMAGE
  $DOCKER pull $RSCRIPT_TXIMPORT_IMAGE
  $DOCKER pull $PIGZ_IMAGE

  COWSAY="$DRUN $COWSAY_IMAGE $COWSAY"
  PREFETCH="$DRUN -v $PWD:/root/ncbi/public/sra $SRA_TOOLKIT_IMAGE $PREFETCH"
  PFASTQ_DUMP="$DRUN $SRA_TOOLKIT_IMAGE $PFASTQ_DUMP"
  FASTQ_DUMP="$DRUN $SRA_TOOLKIT_IMAGE $FASTQ_DUMP"
  FASTERQ_DUMP="$DRUN $SRA_TOOLKIT_IMAGE $FASTERQ_DUMP"
  FASTQC="$DRUN $FASTQC_IMAGE $FASTQC"
  MULTIQC="$DRUN $MULTIQC_IMAGE $MULTIQC"
#   TRIMMOMATIC="$DRUN $TRIMMOMATIC_IMAGE $TRIMMOMATIC"
  # TRIMMOMATIC="$DRUN $TRIMMOMATIC_IMAGE " # fjukstad/trimmomaticのentrypointのため
  TRIMGALORE="$DRUN $TRIMGALORE_IMAGE $TRIMGALORE"
  SALMON="$DRUN $SALMON_IMAGE $SALMON"
#   SALMON="$DRUN $SALMON_IMAGE"
  RSCRIPT_TXIMPORT="$DRUN $RSCRIPT_TXIMPORT_IMAGE $RSCRIPT_TXIMPORT"
  WGET="$DRUN $WGET_IMAGE $WGET"
  PIGZ="$DRUN $PIGZ_IMAGE"

   # docker run --rm -v $PWD:/data -v $PWD:/root/ncbi/public/sra --workdir /data -it inutano/sra-toolkit bash
else
  echo "RUNNING LOCAL"
fi


# if [ $MAX_SPOT_ID = 0 ]; then
if [ $IF_TEST = true ]; then
  $COWSAY "test mode( MAX_SPOT_ID is set)"
  MAX_SPOT_ID="-X 100000"
else
  MAX_SPOT_ID=""
fi

echo $EX_MATRIX_FILE
cat $EX_MATRIX_FILE

# tximport_R.Rを取ってくる。
cp $SCRIPT_DIR/tximport_R.R ./

# trimmomaticのadaptersを取ってくる。
# cp -r $SCRIPT_DIR/adapters/*.fa ./


# # prefetch
# # 先頭一行をとばす。
# for i in `tail -n +2  $1`
# do
# name=`echo $i | cut -d, -f1`
# SRR=`echo $i | cut -d, -f2`
# #   echo "$name $fqfile"
# if [[ ! -f "$SRA_ROOT/$SRR.sra" ]] && [[ ! -f "$SRR.fastq" ]]; then
# $PREFETCH $SRR --max-size $MAXSIZE
# fi
# done
# # pfastq_dump
# for i in `tail -n +2  $1`
# do
# name=`echo $i | cut -d, -f1`
# SRR=`echo $i | cut -d, -f2`
# LAYOUT=`echo $i | cut -d, -f3`
# # SE
# if [ $LAYOUT = SE ]; then
# if [[ ! -f "$SRR.fastq.gz" ]]; then
# $PFASTQ_DUMP --threads $THREADS $SRR.sra
# gzip $SRR.fastq
# fi
# # PE
# else
# if [[ ! -f "$SRR_1.fastq.gz" ]]; then
# $PFASTQ_DUMP --threads $THREADS $SRR.sra --split-files
# gzip $SRR_1.fastq
# gzip $SRR_2.fastq
# fi
# fi
# done



if [ $IF_FASTQ = false ]; then
# fastq_dump
for i in `tail -n +2  $EX_MATRIX_FILE`
do
name=`echo $i | cut -d, -f1`
SRR=`echo $i | cut -d, -f2`
LAYOUT=`echo $i | cut -d, -f3`
# ADAPTER=`echo $i | cut -d, -f4`

<<COMMENTOUT

There is no -N|--minSpotId and no -X|--maxSpotId option.
fasterq-dump version 2.9.1 processes always the whole accession,
although it may support partial access in future versions.

ということで条件分岐させる。

COMMENTOUT

# fasterq_dump
  # SE
  if [ $LAYOUT = SE ]; then
    # fastq_dump
    if [[ ! -f "$SRR.fastq.gz" ]]; then
      if [[ $MAX_SPOT_ID == "" ]]; then
        $FASTERQ_DUMP $SRR --threads $THREADS
        # gzip $SRR.fastq
        $PIGZ $SRR.fastq
      else
        $FASTQ_DUMP $SRR $MAX_SPOT_ID --gzip
      fi
    fi

    # fastqc
    if [[ ! -f "${SRR}_fastqc.zip" ]]; then
      $FASTQC -t $THREADS ${SRR}.fastq.gz
    fi

  # PE
  else
    # fastq_dump
    if [[ ! -f "${SRR}_1.fastq.gz" ]]; then
      if [[ $MAX_SPOT_ID == "" ]]; then
        $FASTERQ_DUMP $SRR --split-files --threads $THREADS
        # gzip ${SRR}_1.fastq
        # gzip ${SRR}_2.fastq
        $PIGZ ${SRR}_1.fastq
        $PIGZ ${SRR}_2.fastq
      else
        $FASTQ_DUMP $SRR $MAX_SPOT_ID --gzip --split-files
      fi
    fi

    # fastqc
    if [[ ! -f "${SRR}_1_fastqc.zip" ]]; then
      $FASTQC -t $THREADS ${SRR}_1.fastq.gz
      $FASTQC -t $THREADS ${SRR}_2.fastq.gz
    fi
  fi
done
fi

if [[ ! -f "multiqc_report_raw_reads.html" ]]; then
  $MULTIQC -n multiqc_report_raw_reads.html .
fi


for i in `tail -n +2  $EX_MATRIX_FILE`
do
if [ $IF_FASTQ = false ]; then
  # fasterq_dump
  name=`echo $i | cut -d, -f1`
  SRR=`echo $i | cut -d, -f2`
  LAYOUT=`echo $i | cut -d, -f3`
  dirname_fq=""
else
  name=`echo $i | cut -d, -f1`
  fq=`echo $i | cut -d, -f2`
  LAYOUT=`echo $i | cut -d, -f3`
  fqname_ext="${fq##*/}"
  # echo $fqname_ext

  # ファイル名を取り出す（拡張子なし）
  basename_fq="${fqname_ext%.*.*}"
  dirname_fq=`dirname $fq`
  dirname_fq=${dirname_fq}/
  SRR=${basename_fq}
fi


# trim_galore
# SE
if [ $LAYOUT = SE ]; then
  if [[ ! -f "${dirname_fq}${SRR}_trimmed.fq.gz" ]]; then
    $TRIMGALORE ${dirname_fq}${SRR}.fastq.gz
  fi

  # fastqc
  if [[ ! -f "${dirname_fq}${SRR}_trimmed_fastqc.zip" ]]; then
    $FASTQC -t $THREADS ${dirname_fq}${SRR}_trimmed.fq.gz
  fi

# PE
else
  # trimmomatic
  if [[ ! -f " ${dirname_fq}${SRR}_1_val_1.fq.gz" ]]; then
    $TRIMGALORE --paired ${dirname_fq}${SRR}_1.fastq.gz ${dirname_fq}${SRR}_2.fastq.gz
  fi

  # fastqc
  if [[ ! -f "${dirname_fq}${SRR}_1_val_1_fastqc.zip" ]]; then
    $FASTQC -t $THREADS ${dirname_fq}${SRR}_1_val_1.fq.gz
    $FASTQC -t $THREADS ${dirname_fq}${SRR}_2_val_2.fq.gz
  fi
fi
done
# download $REF_TRANSCRIPT
if [[ ! -f "$REF_TRANSCRIPT" ]]; then
  $WGET $BASE_REF_TRANSCRIPT/$REF_TRANSCRIPT
fi

# # download $REF_GTF
# if [[ ! -f "$REF_GTF" ]]; then
#   wget $BASE_REF_TRANSCRIPT/$REF_GTF
# fi

# instance salmon index
if [[ ! -d "$SALMON_INDEX" ]]; then
  $SALMON index --threads $THREADS --transcripts $REF_TRANSCRIPT --index $SALMON_INDEX --type quasi -k 31 --gencode
fi

for i in `tail -n +2  $EX_MATRIX_FILE`
do
  if [ $IF_FASTQ = false ]; then
    # fasterq_dump
    name=`echo $i | cut -d, -f1`
    SRR=`echo $i | cut -d, -f2`
    LAYOUT=`echo $i | cut -d, -f3`
    dirname_fq=""
  else
    name=`echo $i | cut -d, -f1`
    fq=`echo $i | cut -d, -f2`
    LAYOUT=`echo $i | cut -d, -f3`
    fqname_ext="${fq##*/}"
    # echo $fqname_ext

    # ファイル名を取り出す（拡張子なし）
    basename_fq="${fqname_ext%.*.*}"
    dirname_fq=`dirname $fq`
    dirname_fq=${dirname_fq}/
    SRR=${basename_fq}
  fi

  # SE
  if [ $LAYOUT = SE ]; then
    if [[ ! -f "salmon_output_${SRR}/quant.sf" ]]; then
      mkdir salmon_output_${SRR}
      # libtype auto detection mode
      $SALMON quant -i $SALMON_INDEX \
      -l A \
      -r ${dirname_fq}${SRR}_trimmed.fq.gz \
      -p $THREADS \
      -o salmon_output_${SRR} \
      --gcBias \
      --validateMappings
#       -g $REF_GTF
    fi

   # PE
  else
    if [[ ! -f "salmon_output_${SRR}/quant.sf" ]]; then
      mkdir salmon_output_${SRR}
      # libtype auto detection mode
      $SALMON quant -i $SALMON_INDEX \
      -l A \
      -1 ${dirname_fq}${SRR}_1_val_1.fq.gz \
      -2 ${dirname_fq}${SRR}_2_val_2.fq.gz \
      -p $THREADS \
      -o salmon_output_${SRR} \
      --gcBias \
      --validateMappings
#       -g $REF_GTF
    fi
  fi
done

# multiqc
if [[ ! -f "multiqc_report.html" ]]; then
  $MULTIQC -n multiqc_report.html .
fi

# download $TX2SYMBOL
if [[ ! -f "$TX2SYMBOL" ]]; then
  $WGET $BASE_REF_TRANSCRIPT/$TX2SYMBOL
fi

# tximport
if [[ ! -f "counttable.tsv" ]]; then
  $RSCRIPT_TXIMPORT tximport_R.R $TX2SYMBOL $EX_MATRIX_FILE
fi


# if [[ "$RUNINDOCKER" -eq "1" ]]; then
#
#   chmod 755 .
#
# fi
