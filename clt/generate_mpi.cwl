cwlVersion: v1.2
class: CommandLineTool
hints:
  InplaceUpdateRequirement:
    inplaceUpdate: true
requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.cmtsolution)
        entryname: DATA/CMTSOLUTION
      - entry: $(inputs.parfile)
        entryname: DATA/Par_file
      - entry: $(inputs.stations)
        entryname: DATA/STATIONS
      - entry: $(inputs.database)
        entryname: $(inputs.localpath)
        writable: true
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: $(inputs.processes)
baseCommand: [mpirun]
arguments:
  - position: 2
    valueFrom: xgenerate_databases
inputs:
  cmtsolution: File
  database: Directory
  localpath: string
  parfile: File
  processes:
    type: int
    inputBinding:
      position: 1
      prefix: -np
  stations: File
outputs:
  db:
    type: Directory
    outputBinding:
      glob: $(inputs.localpath)
  outfile:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/output_generate_databases.txt
  surfaceheader:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/surface_from_mesher.h
  valuesheader:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/values_from_mesher.h