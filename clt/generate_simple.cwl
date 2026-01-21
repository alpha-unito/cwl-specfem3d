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
      - entry: $(inputs.tomography)
        entryname: $(inputs.tomography_path)
  InlineJavascriptRequirement: {}
baseCommand: [xgenerate_databases]
inputs:
  cmtsolution: File
  database: Directory
  localpath: string
  parfile: File
  stations: File
  tomography: Directory?
  tomography_path: string?
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