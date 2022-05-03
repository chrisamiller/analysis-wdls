version 1.0

task varscanGermline {
  input {
    File bam
    File bam_bai
    File reference
    File reference_fai
    File reference_dict
    Int strand_filter = 0
    Int min_coverage = 8
    Float min_var_freq = 0.1
    Int min_reads = 2
    Float p_value = 0.99
    String sample_name
    File? roi_bed
    Int preemptible_tries = 3
}

  Int space_needed_gb = 10
  runtime {
    preemptible: preemptible_tries
    memory: "12GB"
    cpu: 2
    docker: "mgibio/varscan_helper-cwl:1.0.0"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = "output.vcf"
  command <<<
    /usr/bin/varscan_germline_helper.sh \
    ~{bam} \
    ~{reference} \
    ~{strand_filter} \
    ~{min_coverage} \
    ~{min_var_freq} \
    ~{min_reads} \
    ~{p_value} \
    ~{sample_name} \
    ~{outfile} \
    ~{roi_bed}

  >>>

  output {
    File variants = outfile
  }
}
