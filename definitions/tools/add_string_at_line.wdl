version 1.0

task addStringAtLine {
  input {
    File input_file
    Int line_number
    String some_text
    String output_name = basename(input_file) + ".commented"
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(2*size(input_file, "GB"))
  runtime {
    preemptible: preemptible_tries
    docker: "ubuntu:xenial"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    awk -v n=~{line_number} -v s="~{some_text}" 'NR == n {print s} {print}' > ~{output_name}
  >>>

  output {
    File output_file = output_name
  }
}
