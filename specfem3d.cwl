cwlVersion: v1.2
class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
inputs:
  cmtsolution: File
  meshdir: Directory
  parfile: File
  stations: File
outputs:
  graphics:
    type: File
    outputSource: simulate/graphics
  headers:
    type: File[]
    outputSource:
      - generate/surfaceheader
      - generate/valuesheader
  moviedata:
    type: File[]
    outputSource: simulate/moviedata
  outfiles:
    type: File[]
    outputSource:
      - generate/outfile
      - simulate/outsolver
      - simulate/outsources
      - simulate/outstations
      - simulate/starttimeloop
  seismograms:
    type: File[]
    outputSource: simulate/seismograms
  shakingdata:
    type: File
    outputSource: simulate/shakingdata
  timestamps:
    type: File[]
    outputSource: simulate/timestamps
steps:
  get_local_path:
    run: clt/get_local_path.cwl
    in:
      parfile: parfile
    out: [out]
  get_processes:
    run: clt/get_processes.cwl
    in:
      parfile: parfile
    out: [out]
  decompose:
    run: clt/decompose.cwl
    in:
      cmtsolution: cmtsolution
      meshdir: meshdir
      localpath: get_local_path/out
      parfile: parfile
      processes: get_processes/out
      stations: stations
    out: [outdir]
  generate:
    run: generate.cwl
    in:
      cmtsolution: cmtsolution
      database: decompose/outdir
      localpath: get_local_path/out
      parfile: parfile
      processes: get_processes/out
      stations: stations
    out: [db, outfile, surfaceheader, valuesheader]
  simulate:
    run: simulate.cwl
    in:
      cmtsolution: cmtsolution
      database: generate/db
      localpath: get_local_path/out
      parfile: parfile
      processes: get_processes/out
      stations: stations
      surfaceheader: generate/surfaceheader
      valuesheader: generate/valuesheader
    out: [graphics, moviedata, outsolver, outsources, outstations, seismograms, shakingdata, starttimeloop, timestamps]