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
outputs:
  db:
    type: Directory
    outputSource:
      - generate_simple/db
      - generate_mpi/db
    pickValue: the_only_non_null
  outfile:
    type: File
    outputSource:
      - generate_simple/outfile
      - generate_mpi/outfile
    pickValue: the_only_non_null
  surfaceheader:
    type: File
    outputSource:
      - generate_simple/surfaceheader
      - generate_mpi/surfaceheader
    pickValue: the_only_non_null
  valuesheader:
    type: File
    outputSource:
      - generate_simple/valuesheader
      - generate_mpi/valuesheader
    pickValue: the_only_non_null
steps:
  generate_simple:
    when: $(inputs.processes == 1)
    run: clt/generate_simple.cwl
    in:
      cmtsolution: cmtsolution
      database: database
      localpath: localpath
      parfile: parfile
      stations: stations
    out: [db, outfile, surfaceheader, valuesheader]
  generate_mpi:
    when: $(inputs.processes > 1)
    run: clt/generate_mpi.cwl
    in:
      cmtsolution: cmtsolution
      database: database
      localpath: localpath
      parfile: parfile
      processes: processes
      stations: stations
    out: [db, outfile, surfaceheader, valuesheader]