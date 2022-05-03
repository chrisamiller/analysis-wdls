version 1.0

task bedgraphToBigwig {
  input {
    Array[File] methylation_bedgraph
    File reference_sizes
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(methylation_bedgraph, "GB") + size(reference_sizes, "GB"))
  runtime {
    preemptible: preemptible_tries
    docker: "mgibio/bisulfite:v1.4"
    memory: "32GB"
    cpu: 1
    disks: "local ~{space_needed_gb} SSD"
  }

  command <<<
    set -eou pipefail
    BEDGRAPHS=(~{sep=" " methylation_bedgraph})
    for FILE in "${BEDGRAPHS[@]}"
    do
        filename=$(basename "$FILE" .bedgraph)
        /usr/bin/bedGraphToBigWig "$FILE" ~{reference_sizes} "$filename.bw"
    done
  >>>

  output {
    Array[File] methylation_bigwig = glob("*.bw")
  }
}
