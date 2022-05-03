version 1.0

task bgzip {
  input {
    File file
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(file, "GB")*2)
  runtime {
    preemptible: preemptible_tries
    memory: "4GB"
    docker: "quay.io/biocontainers/samtools:1.11--h6270b1f_0"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = basename(file) + ".gz"
  command <<<
    /usr/local/bin/bgzip -c ~{file} > ~{outfile}
  >>>

  output {
    File bgzipped_file = outfile
  }
}
