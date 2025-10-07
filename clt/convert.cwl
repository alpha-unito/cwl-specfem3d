cwlVersion: v1.2
class: CommandLineTool
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.moviedata)
  InlineJavascriptRequirement:
    expressionLib:
      - { $include: parfile.js }
baseCommand: [mpirun]
arguments:
  - position: 3
    prefix: --dt
    valueFrom: "$( parseFloat((new ParFileParser(inputs.parfile.contents)).get('DT')) )"
inputs:
  interpolation:
    type:
      type: record
      fields:
        script:
          type: File
          inputBinding:
            position: 2
        step:
          type: float
          inputBinding:
            position: 4
            prefix: --dx
  moviedata: File[]
  parfile: File
  processes:
    type: int
    inputBinding:
      position: 1
      prefix: -np
outputs:
  full:
    type: File
    outputBinding:
      glob: "*_full.xdmf"
  pgv:
    type: File
    outputBinding:
      glob: "*_pgv.xdmf"
  vz:
    type: File
    outputBinding:
      glob: "*_vz.xdmf"