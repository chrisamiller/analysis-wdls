version 1.0

task pvacseqCombineVariants {
  input {
    File reference
    File reference_fai
    File reference_dict
    File germline_vcf
    File germline_vcf_tbi
    File somatic_vcf
    File somatic_vcf_tbi
    Int preemptible_tries = 3
  }

  Float reference_size = size([reference, reference_fai, reference_dict], "GB")
  Float vcf_size = size([germline_vcf, germline_vcf_tbi, somatic_vcf, somatic_vcf_tbi], "GB")
  Int space_needed_gb = 10 + round(reference_size + 2*vcf_size)
  runtime {
    preemptible: preemptible_tries
    memory: "9GB"
    bootDiskSizeGb: 25
    docker: "mgibio/gatk-cwl:3.6.0"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = "combined_somatic_plus_germline.vcf"
  command <<<
    /usr/bin/java -Xmx8g -jar /opt/GenomeAnalysisTK.jar -T CombineVariants \
    --assumeIdenticalSamples -o ~{outfile} \
    -R ~{reference} \
    -V ~{germline_vcf} \
    -V ~{somatic_vcf}
  >>>

  output { File combined_vcf = outfile }
}
