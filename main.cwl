cwlVersion: v1.2
class: Workflow

$namespaces:
  s: https://schema.org/

$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-9290-2017
    s:email: mailto:iacopo.colonnelli@unito.it
    s:name: Iacopo Colonnelli

s:codeRepository: https://github.com/alpha-unito/cwl-specfem3d
s:dateCreated: "2025-06-09"
s:license: https://spdx.org/licenses/Apache-2.0

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  cmtsolutions: File[]
  interpolation:
    type:
      type: record
      fields:
        script: File
        step: float
  meshdir: Directory
  parfiles: File[]
  reduction:
    type:
      type: record
      fields:
        script: File
  stations: File[]

outputs:
  aggregated:
    type: File
    outputSource: reduce/aggregated
  full:
    type: File[]
    outputSource: specfem3d/full
  graphics:
    type: File[]
    outputSource: specfem3d/graphics
  headers:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: specfem3d/headers
  outfiles:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: specfem3d/outfiles
  pgv:
    type: File[]
    outputSource: specfem3d/pgv
  seismograms:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: specfem3d/seismograms
  shakingdata:
    type: File[]
    outputSource: specfem3d/shakingdata
  vz:
    type: File[]
    outputSource: specfem3d/vz
steps:
  specfem3d:
    run: specfem3d.cwl
    in:
      cmtsolution: cmtsolutions
      interpolation: interpolation
      meshdir: meshdir
      parfile: parfiles
      stations: stations
    scatter: [cmtsolution, parfile, stations]
    scatterMethod: dotproduct
    out: [full, graphics, headers, outfiles, pgv, seismograms, shakingdata, vz]
  reduce:
    run: clt/reduce.cwl
    in:
      full: specfem3d/full
      reduction: reduction
    out: [aggregated]