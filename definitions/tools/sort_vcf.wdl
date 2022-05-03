version 1.0

task sortVcf {
  input {
    File vcf
    File? reference_dict
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size(vcf, "GB") + size(reference_dict, "GB"))
  runtime {
    preemptible: preemptible_tries
    memory: "18GB"
    docker: "broadinstitute/picard:2.23.6"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = "sorted.vcf"
  command <<<
    /usr/bin/java -Xmx16g -jar /usr/picard/picard.jar SortVcf \
    O=~{outfile} \
    I=~{vcf} \
    ~{if defined(reference_dict) then "SEQUENCE_DICTIONARY=~{reference_dict}" else ""}
  >>>

  output {
    File sorted_vcf = outfile
  }
}
