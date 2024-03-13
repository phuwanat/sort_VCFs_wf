version 1.0

workflow sort_VCFs {

    meta {
	author: "Shloka Negi edited by Phuwanat"
        email: "shnegi@ucsc.edu"
        description: "Sort VCF"
    }

    parameter_meta {
        VCF_FILES: "List of VCFs to sort. Can be gzipped/bgzipped."
    }

    input {
        Array[File] vcf_files
    }

    scatter(this_file in vcf_files) {
		call run_sorting { 
			input: vcf = this_file, disk = disk, memory = memory, preemptible = preemptible
		}
	}

    output {
        Array[File] sorted_vcf = run_sorting.out_file
    }

}

task run_sorting {
    input {
        File vcf
        Int memSizeGB = 8
        Int threadCount = 2
        Int diskSizeGB = 5*round(size(vcf, "GB")) + 20
    }
    
    command <<<
	bcftools sort -m 2G -Oz -o samp_$FID.sorted.vcf.gz vcf
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
