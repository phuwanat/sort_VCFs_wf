version 1.0

workflow sort_VCFs {

    meta {
	author: "Shloka Negi edited by Phuwanat"
        email: "shnegi@ucsc.edu"
        description: "Sort VCF"
    }

     input {
        Array[File] vcf_files
    }

    scatter(this_file in vcf_files) {
		call run_sorting { 
			input: vcf = this_file
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
	String out_name = basename(vcf, ".sorted.vcf.gz")
    }
    
    command <<<
	bcftools sort -m 2G -Oz -o ~{out_name} vcf
    >>>

    output {
        File out_file = select_first(glob("*.sorted.vcf.gz"))
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 2
    }

}
