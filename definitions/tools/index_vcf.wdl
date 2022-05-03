version 1.0

task indexVcf {
  input {
    File vcf
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(3*size(vcf, "GB"))
  runtime {
    preemptible: preemptible_tries
    docker: "quay.io/biocontainers/samtools:1.11--h6270b1f_0"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    cp ~{vcf} ~{basename(vcf)}
    /usr/local/bin/tabix -p vcf ~{basename(vcf)}
  >>>
  output {
    File indexed_vcf = basename(vcf)
    File indexed_vcf_tbi = basename(vcf) + ".tbi"
  }
}

workflow wf {
  input { 
    File vcf 
    Int preemptible_tries = 3
  }
  call indexVcf {
    input: 
      vcf=vcf,
      preemptible_tries=preemptible_tries
  }
}
