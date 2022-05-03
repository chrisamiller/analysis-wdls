version 1.0

import "../subworkflows/fp_filter.wdl" as ff
import "../subworkflows/pindel_cat.wdl" as pc
import "../tools/bgzip.wdl" as b
import "../tools/cat_all.wdl" as ca
import "../tools/index_vcf.wdl" as iv
import "../tools/pindel_somatic_filter.wdl" as psf
import "../tools/remove_end_tags.wdl" as ret
import "../tools/split_interval_list_to_bed.wdl" as siltb

workflow pindel {
  input {
    File reference
    File reference_fai
    File reference_dict
    File tumor_bam
    File tumor_bam_bai
    File normal_bam
    File normal_bam_bai
    File interval_list
    String tumor_sample_name
    String normal_sample_name
    Int insert_size = 400
    Int scatter_count = 50
    Int preemptible_tries = 3
  }

  call siltb.splitIntervalListToBed {
    input:
    interval_list=interval_list,
    scatter_count=scatter_count,
    preemptible_tries=preemptible_tries
  }

  scatter(region_file in splitIntervalListToBed.split_beds) {
    call pc.pindelCat {
      input:
      reference=reference,
      reference_fai=reference_fai,
      reference_dict=reference_dict,
      tumor_bam=tumor_bam,
      tumor_bam_bai=tumor_bam_bai,
      normal_bam=normal_bam,
      normal_bam_bai=normal_bam_bai,
      region_file=region_file,
      insert_size=insert_size,
      tumor_sample_name=tumor_sample_name,
      normal_sample_name=normal_sample_name,
      preemptible_tries=preemptible_tries
    }
  }

  call ca.catAll {
    input: 
    region_pindel_outs=pindelCat.per_region_pindel_out,
    preemptible_tries=preemptible_tries
  }

  call psf.pindelSomaticFilter as somaticFilter {
    input:
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    pindel_output_summary=catAll.all_region_pindel_head,
    preemptible_tries=preemptible_tries
  }

  call b.bgzip {
    input: 
    file=somaticFilter.vcf,
    preemptible_tries=preemptible_tries
  }

  call iv.indexVcf as index {
    input: 
    vcf=bgzip.bgzipped_file,
    preemptible_tries=preemptible_tries
  }

  call ret.removeEndTags {
    input:
    vcf=index.indexed_vcf,
    vcf_tbi=index.indexed_vcf_tbi,
    preemptible_tries=preemptible_tries
  }

  call iv.indexVcf as reindex {
    input: 
    vcf=removeEndTags.processed_vcf,
    preemptible_tries=preemptible_tries
  }

  call ff.fpFilter as filter {
    input:
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    bam=tumor_bam,
    bam_bai=tumor_bam_bai,
    vcf=reindex.indexed_vcf,
    vcf_tbi=reindex.indexed_vcf_tbi,
    variant_caller="pindel",
    sample_name=tumor_sample_name,
    preemptible_tries=preemptible_tries
  }

  output {
    File unfiltered_vcf = filter.unfiltered_vcf
    File unfiltered_vcf_tbi = filter.unfiltered_vcf_tbi
    File filtered_vcf = filter.filtered_vcf
    File filtered_vcf_tbi = filter.filtered_vcf_tbi
  }
}
