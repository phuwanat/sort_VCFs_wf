# Merge VCFs workflow
Simple workflow that merges individual sample VCFs to generate a single multi-sample VCF, using [bcftools](https://github.com/samtools/bcftools)

## Input considerations
Required - List of VCF file paths. VCFs must be sorted, but not bgzipped. <br>
Optional - Group name after merging

## Test locally
```
miniwdl run --as-me -i test/test.inputs.json workflow.wdl
```
