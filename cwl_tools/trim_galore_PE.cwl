class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com'
id: trim_galore
baseCommand:
  - trim_galore
inputs:
  - id: read1
    type: File
    inputBinding:
      position: 0
  - id: read2
    type: File
    inputBinding:
      position: 0
outputs:
  - id: out1
    type: File
    outputBinding:
      glob: '*_1_val_1.fq*'
  - id: out2
    type: File
    outputBinding:
      glob: '*_2_val_2.fq*'
label: trim_galore
arguments:
  - position: 0
    prefix: ''
    separate: false
    valueFrom: '--paired'
requirements:
  - class: DockerRequirement
    dockerPull: miasteinberg/trim-galore
