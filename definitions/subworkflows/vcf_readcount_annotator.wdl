version 1.0

import "../tools/vcf_readcount_annotator.wdl" as vra

workflow vcfReadcountAnnotator {
  input {
    File vcf
    File snv_bam_readcount_tsv
    File indel_bam_readcount_tsv
    String data_type  # one of [DNA, RNA]
    String sample_name
    Int preemptible_tries = 3
  }

  call vra.vcfReadcountAnnotator as addSnvBamReadcountToVcf {
    input:
    vcf=vcf,
    bam_readcount_tsv=snv_bam_readcount_tsv,
    data_type=data_type,
    sample_name=sample_name,
    variant_type="snv",
    preemptible_tries=preemptible_tries  
  }

  call vra.vcfReadcountAnnotator as addIndelBamReadcountToVcf {
    input:
    vcf=addSnvBamReadcountToVcf.annotated_bam_readcount_vcf,
    bam_readcount_tsv=indel_bam_readcount_tsv,
    data_type=data_type,
    sample_name=sample_name,
    variant_type="indel",
    preemptible_tries=preemptible_tries
  }

  output {
    File annotated_bam_readcount_vcf = addIndelBamReadcountToVcf.annotated_bam_readcount_vcf
  }
}
