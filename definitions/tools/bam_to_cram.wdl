version 1.0

task bamToCram {
  input {
    File reference
    File reference_fai
    File reference_dict
    File bam
    Int preemptible_tries = 3
  }

  Float reference_size = size([reference, reference_fai, reference_dict], "GB")
  Int size_needed_gb = 10 + round(size(bam, "GB") * 2 + reference_size)
  runtime {
    preemptible: preemptible_tries
    docker: "quay.io/biocontainers/samtools:1.11--h6270b1f_0"
    memory: "4GB"
    disks: "local-disk ~{size_needed_gb} SSD"
  }

  String outfile = basename(bam, ".bam") + ".cram"
  command <<<
    /usr/local/bin/samtools view -C -T ~{reference} ~{bam} > ~{outfile}
  >>>

  output {
    File cram = outfile
  }
}

workflow wf {
  input {
    File reference
    File reference_fai
    File reference_dict
    File bam
    Int preemptible_tries = 3
  }

  call bamToCram {
    input:
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    bam=bam,
    preemptible_tries=preemptible_tries
  }
}
