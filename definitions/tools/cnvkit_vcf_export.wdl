version 1.0

task cnvkitVcfExport {
  input {
    String? segment_filter  # enum ["ampdel" "ci" "cn" "sem"]
    File cns_file
    Boolean male_reference = false
    File? cnr_file
    String output_name
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(2*size([cns_file, cnr_file], "GB"))
  runtime {
    preemptible: preemptible_tries
    memory: "8GB"
    docker: "etal/cnvkit:0.9.5"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    /usr/bin/python /usr/local/bin/cnvkit.py call \
    ~{if(defined(segment_filter)) then "--filter " + segment_filter else ""} \
    ~{cns_file} \
    -y ~{male_reference} -o adjusted.tumor.cns \
    && /usr/bin/python /usr/local/bin/cnvkit.py export vcf adjusted.tumor.cns \
    ~{true="-y" false="" male_reference} \
    ~{if defined(cnr_file) then "--cnr " + cnr_file else ""} \
    -o ~{output_name}
  >>>

  output {
    File cnvkit_vcf = output_name
  }
}
