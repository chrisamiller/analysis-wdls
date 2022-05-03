version 1.0

task filterVcfDepth {
  input {
    File vcf
    Int minimum_depth
    Array[String] sample_names
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(vcf, "GB")*2)
  runtime {
    preemptible: preemptible_tries
    docker: "mgibio/depth-filter:0.1.2"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = "depth_filtered.vcf"
  command <<<
    /opt/conda/bin/python3 /usr/bin/depth_filter.py \
    --minimum_depth ~{minimum_depth} \
    ~{vcf} ~{sep="," sample_names} \
    ~{outfile}
  >>>

  output {
    File depth_filtered_vcf = outfile
  }
}
