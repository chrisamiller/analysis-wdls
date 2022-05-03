version 1.0

task verifyBamId {
  input {
    File vcf
    File bam
    File bam_bai
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size([bam, bam_bai, vcf], "GB"))
  runtime {
    preemptible: preemptible_tries
    docker: "mgibio/verify_bam_id-cwl:1.1.3"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String bamroot = basename(bam, ".bam")
  String outroot = "~{bamroot}.VerifyBamId"
  command <<<
    /usr/local/bin/verifyBamID --out ~{outroot} --vcf ~{vcf} --bam ~{bam} --bai ~{bam_bai}
  >>>

  output {
    File verify_bam_id_metrics = "~{outroot}.selfSM"
    File verify_bam_id_depth = "~{outroot}.depthSM"
  }
}
