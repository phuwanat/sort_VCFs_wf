version 1.0

workflow merge_VCFs {

    meta {
	author: "Shloka Negi"
        email: "shnegi@ucsc.edu"
        description: "Merge individual sample VCFs to create a unified multi-sample VCF, optionally allowing for modification of sample names."
    }

    parameter_meta {
        VCF_FILES: "List of VCFs to merge. Can be gzipped/bgzipped."
        SAMPLE_NAMES: "List of new sample names for each input VCF"
        GROUP_NAME: "Name of group after merging"
        SORT_VCFS: "Should the input VCF be sorted? Default is no (i.e. assuming they're already sorted)"
    }

    input {
        Array[File] VCF_FILES
        Array[String] SAMPLE_NAMES = []
        String GROUP_NAME = 'samples'
        Boolean SORT_VCFS = false
    }
    
    call run_merging {
        input:
        vcf_files=VCF_FILES,
        sample_names = SAMPLE_NAMES,
        group_name=GROUP_NAME,
        sort_vcfs=SORT_VCFS
    }

    output {
        File merged_vcf = run_merging.vcf
        File merged_vcf_index = run_merging.vcf_index
    }

}

task run_merging {
    input {
        Array[File] vcf_files
        Array[String] sample_names = []
        String group_name = 'samples'
        Boolean sort_vcfs = false
        Int memSizeGB = 8
        Int threadCount = 2
        Int diskSizeGB = 5*round(size(vcf_files, "GB")) + 20
    }
    
    command <<<
        set -eux -o pipefail

        ## list VCFs
        ## eventually sort them first
        FID=1
        for FF in ~{sep=" " vcf_files}
        do
            if [ ~{sort_vcfs} == "true" ]
            then
                bcftools sort -m 2G -Oz -o samp_$FID.vcf.gz $FF
                echo samp_$FID.vcf.gz >> vcf_list.txt
                FID=$((FID+1))
            else
                echo $FF >> vcf_list.txt
            fi
        done
        
        ## Run bcftools merge
        bcftools merge --no-index -m both -l vcf_list.txt --threads ~{threadCount} -Oz -o ~{group_name}.merged.vcf.gz

        ## if specified, change sample names in merged VCF
        if [[ "~{sep='' sample_names}" != "" ]]; then
            for SAMP in ~{sep=" " sample_names}
            do
                echo $SAMP >> sampnames.txt
            done

            bcftools reheader -s sampnames.txt --threads ~{threadCount} -o ~{group_name}.renamed.merged.vcf.gz ~{group_name}.merged.vcf.gz

            ## replace the VCF
            mv ~{group_name}.renamed.merged.vcf.gz ~{group_name}.merged.vcf.gz
        fi

        ## Create index of merged VCF
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
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 2
    }

}
