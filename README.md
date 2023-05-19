# Merge VCFs workflow
Merge individual sample VCFs to create a unified multi-sample VCF, optionally allowing for modification of sample names.

## Input considerations
* List of VCF file paths. VCFs must be sorted, optionally bgzipped. (REQUIRED)
* List of new sample names for each input VCF in the order they appear in the VCFs list. (OPTIONAL)
* Group name after merging. Default - "samples" (OPTIONAL)

## Test locally
```
miniwdl run --as-me -i test/test.inputs.json workflow.wdl
```
