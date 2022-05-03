version 1.0

task smoove {
  input {
    Array[File] bams
    String cohort_name = "SV"
    File reference
    File reference_fai
    File reference_dict
    File? exclude_regions
    Int preemptible_tries = 3
  }

  Int cores = 4
  Float reference_size = size([reference, reference_fai, reference_dict], "GB")
  Int space_needed_gb = 10 + round(2*(size(bams, "GB") + reference_size))
  runtime {
    preemptible: preemptible_tries
    memory: "20GB"
    cpu: cores
    bootDiskSizeGb: 10
    docker: "brentp/smoove:v0.2.7"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    /usr/bin/smoove call --processes ~{cores} -F \
    --genotype ~{sep=" " bams} \
    --name ~{cohort_name} --fasta ~{reference} \
    ~{if defined(exclude_regions) then "--exclude" else ""}
  >>>

  output {
    File output_vcf = cohort_name + "-smoove.genotyped.vcf.gz"
    File output_vcf_csi = cohort_name + "-smoove.genotyped.vcf.gz.csi"
  }
}
