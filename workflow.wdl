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
	String out_name = basename(vcf, ".vcf.gz")
    }
    
    command <<<
	tabix -p vcf ~{vcf}
	bcftools view -i 'FILTER="PASS"' -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX -Oz -o ~{out_name}.included.vcf.gz ~{vcf}
	tabix -p vcf ~{out_name}.included.vcf.gz
	bcftools annotate -x INFO,FORMAT ~{out_name}.included.vcf.gz -Oz -o ~{out_name}.included2.vcf.gz
	tabix -p vcf ~{out_name}.included2.vcf.gz
	bcftools sort -m 2G -Oz -o ~{out_name}.sorted.vcf.gz ~{out_name}.included2.vcf.gz
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
