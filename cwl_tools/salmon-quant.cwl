class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com'
baseCommand:
  - salmon
inputs:
  - id: index
    type: Directory
    inputBinding:
      position: 0
      prefix: '--index'
  - id: inf1
    type: File
    inputBinding:
      position: 1
      prefix: '-1'
  - id: inf2
    type: File
    inputBinding:
      position: 2
      prefix: '-2'
  - default: A
    'sbg:toolDefaultValue': A
    id: libType
    type: string
    inputBinding:
      position: 0
      prefix: '--libType'
  - id: quantdir
    type: string
    inputBinding:
      position: 0
      prefix: '--output'
  - 'sbg:toolDefaultValue': '4'
    id: threads
    type: int?
    inputBinding:
      position: 0
      prefix: '--threads'
    doc: |
      1
      int: number of threads to run Salmon
outputs:
  - id: quantdir
    type: Directory
    outputBinding:
      glob: .
arguments:
  - quant
  - position: 4
    prefix: ''
    valueFrom: '--gcBias'
  - position: 5
    prefix: ''
    valueFrom: '--validateMappings'
requirements:
  - class: DockerRequirement
    dockerPull: combinelab/salmon
