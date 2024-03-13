version 1.0

workflow merge_VCFs {

    meta {
	author: "Shloka Negi"
        email: "shnegi@ucsc.edu"
        description: "Merge individual sample VCFs to create a unified multi-sample VCF, optionally allowing for modification of sample names."
    }

    parameter_meta {
        VCF_FILES: "List of VCFs to merge. Can be gzipped/bgzipped."
    }

    input {
        Array[File] VCF_FILES
    }
    
    call run_merging {
        input:
        vcf_files=VCF_FILES
    }

    output {
        File sorted_vcf = run_merging.vcf
        File merged_vcf_index = run_merging.vcf_index
    }

}

task run_merging {
    input {
        Array[File] vcf_files
        Int memSizeGB = 8
        Int threadCount = 2
        Int diskSizeGB = 5*round(size(vcf_files, "GB")) + 20
    }
    
    command <<<
	bcftools sort -m 2G -Oz -o samp_$FID.sorted.vcf.gz $FF
    >>>

    output {
        File vcf = "~{group_name}.merged.vcf.gz"
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 2
    }

}
