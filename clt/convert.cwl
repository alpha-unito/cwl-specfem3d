cwlVersion: v1.2
class: CommandLineTool
hints:
  SoftwareRequirement:
    packages:
      - package: h5py
      - package: meshio
      - package: mpi4py
      - package: numpy
      - package: scipy
requirements:
  InitialWorkDirRequirement:
    listing:
      - $(inputs.moviedata)
  InlineJavascriptRequirement:
    expressionLib:
      - { $include: parfile.js }
  ResourceRequirement:
    coresMin: $(inputs.interpolation.processes)
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
        processes:
          type: int
          inputBinding:
            position: 1
            prefix: -np
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
  parfile:
    type: File
    loadContents: true
outputs:
  full:
    type: File
    outputBinding:
      glob: "*_full.xdmf"
    secondaryFiles: ^.h5
  pgv:
    type: File
    outputBinding:
      glob: "*_pgv.xdmf"
    secondaryFiles: ^.h5
  vz:
    type: File
    outputBinding:
      glob: "*_vz.xdmf"
    secondaryFiles: ^.h5