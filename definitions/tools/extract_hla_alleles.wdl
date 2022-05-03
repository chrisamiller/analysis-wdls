version 1.0

task extractHlaAlleles {
  input {
    File file
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(file, "GB"))
  runtime {
    preemptible: preemptible_tries
    memory: "2GB"
    docker: "ubuntu:xenial"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outname = "helper.txt"
  command <<<
    /usr/bin/awk '{getline; printf "HLA-"$2 "\nHLA-"$3 "\nHLA-"$4 "\nHLA-"$5 "\nHLA-"$6 "\nHLA-"$7}' ~{file} > ~{outname}
  >>>

  output {
    Array[String] allele_string = read_lines(outname)
    File allele_file = outname
  }
}

workflow wf {
  input { 
    File file
    Int preemptible_tries = 3
  }
  call extractHlaAlleles { 
    input: 
      file=file,
      preemptible_tries=preemptible_tries
  }
}
