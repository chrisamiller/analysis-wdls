version 1.0

task biscuitPileup {
  input {
    File bam
    File reference
    File reference_fai
    Int preemptible_tries = 3
  }
  Int cores = 4

  Int space_needed_gb = 10 + round(2*size([bam, reference], "GB"))
  runtime {
    preemptible: preemptible_tries
    memory: "48GB"
    cpu: cores
    docker: "mgibio/biscuit:0.3.8"
    disks: "local ~{space_needed_gb} SSD"
    bootDiskSizeGb: space_needed_gb
  }

  command <<<
    set -eo pipefail
    /usr/bin/biscuit pileup -q ~{cores} -w pileup_stats.txt  "~{reference}" "~{bam}" | /opt/htslib/bin/bgzip > out.vcf
  >>>

  output {
    File vcf = "output.vcf"
  }
}
