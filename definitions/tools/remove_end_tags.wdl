version 1.0

task removeEndTags {
  input {
    File vcf
    File vcf_tbi
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(vcf, "GB")*2)
  runtime {
    preemptible: preemptible_tries
    memory: "4GB"
    docker: "mgibio/bcftools-cwl:1.12"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = "pindel.noend.vcf.gz"
  command <<<
    /opt/bcftools/bin/bcftools annotate -x INFO/END -Oz -o ~{outfile} ~{vcf}
  >>>

  output {
    File processed_vcf = outfile
  }
}

workflow wf {
  input {
    File vcf
    File vcf_tbi
    Int preemptible_tries = 3
  }

  call removeEndTags {
    input:
    vcf=vcf,
    vcf_tbi=vcf_tbi,
    preemptible_tries=preemptible_tries
  }
}
