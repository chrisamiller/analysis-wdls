version 1.0

task mergeVcf {
  input {
    Array[File] vcfs
    Array[File] vcf_tbis
    String merged_vcf_basename = "merged"
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(2*(size(vcfs, "GB") + size(vcf_tbis, "GB")))
  runtime {
    preemptible: preemptible_tries
    docker: "mgibio/bcftools-cwl:1.12"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String output_file = merged_vcf_basename + ".vcf.gz"
  command <<<
    /opt/bcftools/bin/bcftools concat --allow-overlaps --remove-duplicates --output-type z -o ~{output_file} ~{sep=" " vcfs}
  >>>

  output {
    File merged_vcf = output_file
  }
}
