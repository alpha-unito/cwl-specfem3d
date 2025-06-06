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
  meshdir: Directory
  parfiles: File[]
  stations: File[]

outputs:
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
  moviedata:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: specfem3d/moviedata
  outfiles:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: specfem3d/outfiles
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
  timestamps:
    type:
      type: array
      items:
        type: array
        items: File
    outputSource: specfem3d/timestamps

steps:
  specfem3d:
    run: specfem3d.cwl
    in:
      cmtsolution: cmtsolutions
      meshdir: meshdir
      parfile: parfiles
      stations: stations
    scatter: [cmtsolutions, parfiles, stations]
    scatterMethod: dotproduct
    out: [graphics, headers, moviedata, outfiles, seismograms, shakingdata, timestamps]