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
      - entry: $(inputs.surfaceheader)
        entryname: OUTPUT_FILES/$(inputs.surfaceheader.basename)
      - entry: $(inputs.valuesheader)
        entryname: OUTPUT_FILES/$(inputs.valuesheader.basename)
baseCommand: [mpirun]
arguments:
  - position: 2
    valueFrom: xspecfem3D
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
  surfaceheader: File
  valuesheader: File
outputs:
  graphics:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/sr.vtk
  moviedata:
    type: File[]
    outputBinding:
      glob: OUTPUT_FILES/moviedata*
  outsolver:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/output_solver.txt
  outsources:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/output_list_sources.txt
  outstations:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/output_list_stations.txt
  seismograms:
    type: File[]
    outputBinding:
      glob: "*.sem?"
  shakingdata:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/shakingdata
  starttimeloop:
    type: File
    outputBinding:
      glob: OUTPUT_FILES/starttimeloop.txt
  timestamps:
    type: File[]
    outputBinding:
      glob: OUTPUT_FILES/timestamp*