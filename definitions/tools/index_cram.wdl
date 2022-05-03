version 1.0

task indexCram {
  input { 
    File cram 
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(cram, "GB")*3)
  runtime {
    preemptible: preemptible_tries
    docker: "quay.io/biocontainers/samtools:1.11--h6270b1f_0"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    mv ~{cram} ~{basename(cram)}
    /usr/local/bin/samtools index ~{basename(cram)} ~{basename(cram)}.crai
  >>>

  output {
    File indexed_cram = basename(cram)
    File indexed_cram_crai = "~{basename(cram)}.crai"
  }
}

workflow wf {
  input { 
    File cram 
    Int preemptible_tries = 3
   }
  call indexCram { 
    input: 
      cram=cram,
      preemptible_tries=preemptible_tries
    }
}
