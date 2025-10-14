cwlVersion: v1.2
class: CommandLineTool
hints:
  SoftwareRequirement:
    packages:
      - package: meshio
      - package: mpi4py
      - package: numpy
      - package: scipy
baseCommand: [python]
inputs:
  full:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --file
    inputBinding:
      position: 2
  reduction:
    type:
      type: record
      fields:
        script:
          type: File
          inputBinding:
            position: 1
outputs:
  aggregated:
    type: File
    outputBinding:
      glob: "aggregated_shakemovie_full.xdmf"
    secondaryFiles: ^.h5