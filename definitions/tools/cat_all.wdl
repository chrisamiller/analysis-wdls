version 1.0

task catAll {
  input {
    Array[File] region_pindel_outs
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(region_pindel_outs, "GB")*2)
  runtime {
    preemptible: preemptible_tries
    memory: "4GB"
    docker: "ubuntu:xenial"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    /bin/grep "ChrID" ~{sep=" " region_pindel_outs} > all_region_pindel.head
  >>>

  output {
    File all_region_pindel_head = "all_region_pindel.head"
  }
}
