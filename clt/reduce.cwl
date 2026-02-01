cwlVersion: v1.2
class: CommandLineTool
hints:
  SoftwareRequirement:
    packages:
      - package: meshio
      - package: numpy
requirements:
  InlineJavascriptRequirement:
    expressionLib:
      - { $include: parfile.js }
baseCommand: [python]
arguments:
  - position: 4
    prefix: --dt
    valueFrom: "$( parseFloat((new ParFileParser(inputs.parfile.contents)).get('DT')) )"
inputs:
  full:
    type:
      type: array
      items: File
      inputBinding:
        position: 2
        prefix: --file
  parfile:
    type: File
    loadContents: true
  reduction:
    type:
      type: record
      fields:
        script:
          type: File
          inputBinding:
            position: 1
        scenario:
          type: string?
          inputBinding:
            position: 3
            prefix: --scenario
        seed:
          type: int?
          inputBinding:
            position: 5
            prefix: --seed
outputs:
  aggregated:
    type: File
    outputBinding:
      glob: "aggregated_full.xdmf"
    secondaryFiles: ^.h5