version 1.0

task vtDecompose {
  input {
    File vcf
    File vcf_tbi
    Int preemptible_tries
  }

  Int space_needed_gb = 10 + round(size([vcf, vcf_tbi], "GB")*2)
  runtime {
    preemptible: preemptible_tries
    memory: "4GB"
    docker: "quay.io/biocontainers/vt:0.57721--hf74b74d_1"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    vt decompose -s -o decomposed.vcf.gz ~{vcf}
  >>>

  output {
    File decomposed_vcf = "decomposed.vcf.gz"
  }
}

workflow wf {
  input {
    File vcf
    File vcf_tbi
    Int preemptible_tries = 3
  }

  call vtDecompose {
    input:
    vcf=vcf,
    vcf_tbi=vcf_tbi,
    preemptible_tries=preemptible_tries
  }
}
