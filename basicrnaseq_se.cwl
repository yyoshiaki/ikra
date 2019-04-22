class: Workflow
cwlVersion: v1.0
id: basicrnaseq_se
label: basicRNAseq_SE
$namespaces:
  sbg: 'https://www.sevenbridges.com'
inputs:
  - id: transcripts
    type: File
    'sbg:x': -1946
    'sbg:y': -386
  - id: read2
    type: File
    'sbg:x': -1953.89697265625
    'sbg:y': -794
  - id: read1
    type: File
    'sbg:x': -1941.89697265625
    'sbg:y': -649
outputs:
  - id: index
    outputSource:
      - salmon_index/index
    type: Directory
    'sbg:x': -1421.8984375
    'sbg:y': -250
  - id: quant
    outputSource:
      - salmon_quant/quant
    type: File
    'sbg:x': -1208.89697265625
    'sbg:y': -676
steps:
  - id: salmon_index
    in:
      - id: index
        default: salmon_index_mouse
      - id: threads
        default: 6
      - id: transcripts
        source: transcripts
    out:
      - id: index
    run: cwl_tools/salmon-index.cwl
    'sbg:x': -1705.125
    'sbg:y': -384.5
  - id: trim_galore
    in:
      - id: read1
        source: read1
      - id: read2
        source: read2
    out:
      - id: out1
      - id: out2
    run: cwl_tools/trim_galore_PE.cwl
    label: trim_galore
    'sbg:x': -1672
    'sbg:y': -728
  - id: salmon_quant
    in:
      - id: index
        source: salmon_index/index
      - id: inf1
        source: trim_galore/out1
      - id: inf2
        source: trim_galore/out2
      - id: libType
        default: A
      - id: quantdir
        default: quantdir
      - id: threads
        default: 4
    out:
      - id: quant
    run: cwl_tools/salmon-quant.cwl
    'sbg:x': -1418.89697265625
    'sbg:y': -679
requirements: []
'sbg:toolAuthor': Yoshiaki Yasumizu
