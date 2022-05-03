version 1.0

task stagedRename {
  input {
    File original
    String name
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(original, "GB")*2)
  runtime {
    preemptible: preemptible_tries
    memory: "4GB"
    cpu: 1
    docker: "ubuntu:bionic"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    /bin/mv ~{original} ~{name}
  >>>

  output {
    File replacement = name
  }
}
