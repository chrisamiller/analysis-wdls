version 1.0

task setFilterStatus {
  input {
    File vcf
    File vcf_tbi
    File filtered_vcf
    File filtered_vcf_tbi
    File reference
    File reference_fai
    File reference_dict
    Int preemptible_tries = 3
  }

  Float vcf_size = size([vcf, vcf_tbi, filtered_vcf, filtered_vcf_tbi], "GB")
  Float reference_size = size([reference, reference_fai, reference_dict], "GB")
  Int space_needed_gb = 10 + round(reference_size + vcf_size*2)
  runtime {
    preemptible: preemptible_tries
    disks: "local-disk ~{space_needed_gb} SSD"
    memory: "6GB"
    bootDiskSizeGb: 25
    docker: "mgibio/gatk-cwl:3.6.0"
  }

  String outfile = "output.vcf.gz"
  command <<<
    /usr/bin/java -Xmx4g -jar /opt/GenomeAnalysisTK.jar -T VariantFiltration \
    --maskName processSomatic --filterNotInMask -o ~{outfile} \
    -R ~{reference} --variant ~{vcf} --mask ~{filtered_vcf}
  >>>

  output {
    File merged_vcf = outfile
  }
}

workflow wf {
  input {
    File vcf
    File vcf_tbi
    File filtered_vcf
    File filtered_vcf_tbi
    File reference
    File reference_fai
    File reference_dict
    Int preemptible_tries = 3
  }

  call setFilterStatus {
    input:
    vcf=vcf,
    vcf_tbi=vcf_tbi,
    filtered_vcf=filtered_vcf,
    filtered_vcf_tbi=filtered_vcf_tbi,
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    preemptible_tries=preemptible_tries
  }
}
