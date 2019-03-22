class: Workflow
cwlVersion: v1.0
id: basicrnaseq_se
label: basicRNAseq_SE
$namespaces:
  sbg: 'https://www.sevenbridges.com'
inputs:
  - id: inf1
    type: File
    'sbg:x': -1672.1298828125
    'sbg:y': -659
  - id: inf2
    type: File
    'sbg:x': -1653.1298828125
    'sbg:y': -790
  - id: transcripts
    type: File
    'sbg:x': -1946
    'sbg:y': -386
outputs:
  - id: quantdir
    outputSource:
      - salmon_quant/quantdir
    type: Directory
    'sbg:x': -1187.1298828125
    'sbg:y': -672
steps:
  - id: salmon_quant
    in:
      - id: index
        source: salmon_index/index
      - id: inf1
        source: inf1
      - id: inf2
        source: inf2
      - id: libType
        default: A
      - id: quantdir
        default: out
      - id: threads
        default: 4
    out:
      - id: quantdir
    run: cwl_tools/salmon-quant.cwl
    'sbg:x': -1370
    'sbg:y': -671
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
requirements: []
