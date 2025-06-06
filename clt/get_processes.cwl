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
  out: int
expression: |
  ${ return { out: parseInt((new ParFileParser(inputs.parfile.contents)).get('NPROC')) }; }
