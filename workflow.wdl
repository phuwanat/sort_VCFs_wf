version 1.0

workflow merge_VCFs {

    meta {
	    author: "Shloka Negi"
        email: "shnegi@ucsc.edu"
        description: "Merge individual sample VCFs to generate a single multi-sample VCF"
    }

    parameter_meta {
        VCF_FILES: "List of VCFs to merge. Should be sorted. Can be gzipped/bgzipped."
        GROUP_NAME: "Name of group after merging"
    }

    input {
        Array[File] VCF_FILES
        String GROUP_NAME = 'samples'
    }
  
    call run_merging {
        input:
        vcf_files=VCF_FILES,
        group_name=GROUP_NAME
        
    }

    output {
        File merged_vcf = run_merging.vcf
        File merged_vcf_index = run_merging.vcf_index
    }

}

task run_merging {
    input {
        Array[File] vcf_files
        String group_name = 'samples'
        Int memSizeGB = 8
        Int threadCount = 2
        Int diskSizeGB = 5*round(size(vcf_files, "GB")) + 20
    }
    
    # Write all vcf pathnames to a file
    File vcf_path_names_file = write_lines(vcf_files) 

    command <<<
        set -eux -o pipefail

        ## Run bcftools merge
        bcftools merge --no-index -m both -l vcf_path_names_file --threads ~{threadCount} -Oz -o ~{group_name}.merged.vcf.gz
        bcftools index -t -o ~{group_name}.merged.vcf.gz.tbi ~{group_name}.merged.vcf.gz

    >>>

    output {
        File vcf = "~{group_name}.merged.vcf.gz"
        File vcf_index = "~{group_name}.merged.vcf.gz.tbi"

    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools:1.16--hfe4b78e_1"   # digest: quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa
        preemptible: 2
    }

}
