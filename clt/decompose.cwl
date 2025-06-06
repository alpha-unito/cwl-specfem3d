cwlVersion: v1.2
class: CommandLineTool
requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.cmtsolution)
        entryname: DATA/CMTSOLUTION
      - entry: $(inputs.parfile)
        entryname: DATA/Par_file
      - entry: $(inputs.stations)
        entryname: DATA/STATIONS
      - "$({ class: 'Directory', basename: inputs.localpath, listing: [] })"
  InlineJavascriptRequirement: {}
baseCommand: [xdecompose_mesh]
inputs:
  cmtsolution: File
  localpath:
    type: string
    inputBinding:
      position: 3
  meshdir:
    type: Directory
    inputBinding:
      position: 2
  parfile: File
  processes:
    type: int
    inputBinding:
      position: 1
  stations: File
outputs:
  outdir:
    type: Directory
    outputBinding:
      glob: $(inputs.localpath)
