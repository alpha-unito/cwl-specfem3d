cwlVersion: v1.2
class: Workflow
requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}
inputs:
  cmtsolution: File
  database: Directory
  localpath: string
  parfile: File
  processes: int
  stations: File
  surfaceheader: File
  valuesheader: File
outputs:
  graphics:
    type: File
    outputSource:
      - simulate_simple/graphics
      - simulate_mpi/graphics
    pickValue: the_only_non_null
  moviedata:
    type: File[]
    outputSource:
      - simulate_simple/moviedata
      - simulate_mpi/moviedata
    pickValue: the_only_non_null
  outsolver:
    type: File
    outputSource:
      - simulate_simple/outsolver
      - simulate_mpi/outsolver
    pickValue: the_only_non_null
  outsources:
    type: File
    outputSource:
      - simulate_simple/outsources
      - simulate_mpi/outsources
    pickValue: the_only_non_null
  outstations:
    type: File
    outputSource:
      - simulate_simple/outstations
      - simulate_mpi/outstations
    pickValue: the_only_non_null
  seismograms:
    type: File[]
    outputSource:
      - simulate_simple/seismograms
      - simulate_mpi/seismograms
    pickValue: the_only_non_null
  shakingdata:
    type: File
    outputSource:
      - simulate_simple/shakingdata
      - simulate_mpi/shakingdata
    pickValue: the_only_non_null
  starttimeloop:
    type: File
    outputSource:
      - simulate_simple/starttimeloop
      - simulate_mpi/starttimeloop
    pickValue: the_only_non_null
  timestamps:
    type: File[]
    outputSource:
      - simulate_simple/timestamps
      - simulate_mpi/timestamps
    pickValue: the_only_non_null 
steps:
  simulate_simple:
    when: $(inputs.processes == 1)
    run: clt/simulate_simple.cwl
    in:
      cmtsolution: cmtsolution
      database: database
      localpath: localpath
      parfile: parfile
      stations: stations
      surfaceheader: surfaceheader
      valuesheader: valuesheader
    out: [graphics, moviedata, outsolver, outsources, outstations, seismograms, shakingdata, starttimeloop, timestamps]
  simulate_mpi:
    when: $(inputs.processes > 1)
    run: clt/simulate_mpi.cwl
    in:
      cmtsolution: cmtsolution
      database: database
      localpath: localpath
      parfile: parfile
      processes: processes
      stations: stations
      surfaceheader: surfaceheader
      valuesheader: valuesheader
    out: [graphics, moviedata, outsolver, outsources, outstations, seismograms, shakingdata, starttimeloop, timestamps]