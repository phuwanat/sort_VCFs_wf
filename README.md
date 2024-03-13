# Sort VCFs workflow
Merge individual sample VCFs to create a unified multi-sample VCF, optionally allowing for modification of sample names.

## Input considerations
* List of VCF file paths

## Test locally
```
miniwdl run --as-me -i test.inputs.default.json workflow.wdl
miniwdl run --as-me -i test.inputs.options.json workflow.wdl
```
