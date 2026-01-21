cwlVersion: v1.2
class: ExpressionTool
requirements:
    InlineJavascriptRequirement:
      expressionLib:
        - { $include: parfile.js }
inputs:
  parfile:
    type: File
    loadContents: true
outputs:
  out: string
expression: |
  ${ return { out: (new ParFileParser(inputs.parfile.contents)).get('TOMOGRAPHY_PATH') }; }
