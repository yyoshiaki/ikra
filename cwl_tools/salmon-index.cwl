class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com'
baseCommand:
  - salmon
inputs:
  - 'sbg:toolDefaultValue': salmon_index
    id: index
    type: string
    inputBinding:
      position: 0
      prefix: '--index'
  - 'sbg:toolDefaultValue': '4'
    id: threads
    type: int?
    inputBinding:
      position: 0
      prefix: '--threads'
    doc: |
      1
      int: number of threads to run Salmon
  - id: transcripts
    type: File
    inputBinding:
      position: 0
      prefix: '--transcripts'
outputs:
  - id: index
    type: Directory
    outputBinding:
      glob: '*index*'
arguments:
  - index
  - position: 0
    prefix: '--gencode'
requirements:
  - class: DockerRequirement
    dockerPull: combinelab/salmon
