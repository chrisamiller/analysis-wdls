version 1.0

task splitIntervalListToBed {
  input {
    File interval_list
    Int scatter_count
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(interval_list, "GB")*2)
  runtime {
    preemptible: preemptible_tries
    memory: "6GB"
    docker: "mgibio/cle:v1.4.2"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    /usr/bin/perl /usr/bin/split_interval_list_to_bed_helper.pl OUTPUT="$PWD" INPUT=~{interval_list} SCATTER_COUNT=~{scatter_count}
  >>>

  output {
    Array[File] split_beds = glob("*.interval.bed")
  }
}

workflow wf {
  input {
    File interval_list
    Int scatter_count
    Int preemptible_tries = 3
  }

  call splitIntervalListToBed {
    input:
    interval_list=interval_list,
    scatter_count=scatter_count,
    preemptible_tries=preemptible_tries
  }
}
