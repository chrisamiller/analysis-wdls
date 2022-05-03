version 1.0

import "../subworkflows/fp_filter.wdl" as ff
import "../subworkflows/varscan.wdl" as v
import "../tools/index_vcf.wdl" as iv
import "../tools/intervals_to_bed.wdl" as itb
import "../tools/merge_vcf.wdl" as mv
import "../tools/picard_merge_vcfs.wdl" as pmv
import "../tools/replace_vcf_sample_name.wdl" as rvsn
import "../tools/set_filter_status.wdl" as sfs
import "../tools/split_interval_list.wdl" as sil

workflow varscanPreAndPostProcessing {
  input {
    File reference
    File reference_fai
    File reference_dict

    String tumor_sample_name
    File tumor_bam
    File tumor_bam_bai

    String normal_sample_name
    File normal_bam
    File normal_bam_bai

    File interval_list

    Int strand_filter = 0
    Int min_coverage = 8
    Float min_var_freq = 0.1
    Float p_value = 0.99
    Float? max_normal_freq
    Int scatter_count = 50
    Int preemptible_tries = 3
  }

  call sil.splitIntervalList {
    input:
    interval_list=interval_list,
    scatter_count=scatter_count,
    preemptible_tries=preemptible_tries
  }

  scatter (intervals_segment in splitIntervalList.split_interval_lists) {
    call itb.intervalsToBed {
      input: 
      interval_list=intervals_segment,
      preemptible_tries=preemptible_tries
    }

    call v.varscan {
      input:
      reference=reference,
      reference_fai=reference_fai,
      reference_dict=reference_dict,
      tumor_bam=tumor_bam,
      tumor_bam_bai=tumor_bam_bai,
      normal_bam=normal_bam,
      normal_bam_bai=normal_bam_bai,
      roi_bed=intervalsToBed.interval_bed,
      strand_filter=strand_filter,
      min_coverage=min_coverage,
      min_var_freq=min_var_freq,
      p_value=p_value,
      max_normal_freq=max_normal_freq,
      preemptible_tries=preemptible_tries
    }
  }

  call pmv.picardMergeVcfs as mergeScatteredSomaticSnvs {
    input:
    vcfs=varscan.somatic_snvs,
    sequence_dictionary=reference_dict,
    merged_vcf_basename="somatic_snvs",
    preemptible_tries=preemptible_tries
  }

  call pmv.picardMergeVcfs as mergeScatteredSomaticIndels {
    input:
    vcfs=varscan.somatic_indels,
    sequence_dictionary=reference_dict,
    merged_vcf_basename="somatic_indels",
    preemptible_tries=preemptible_tries
  }

  call pmv.picardMergeVcfs as mergeScatteredSomaticHcSnvs  {
    input:
    vcfs=varscan.somatic_hc_snvs,
    sequence_dictionary=reference_dict,
    merged_vcf_basename="somatic_hc_snvs",
    preemptible_tries=preemptible_tries
  }

  call pmv.picardMergeVcfs as mergeScatteredSomaticHcIndels {
    input:
    vcfs=varscan.somatic_hc_indels,
    sequence_dictionary=reference_dict,
    merged_vcf_basename="somatic_hc_indels",
    preemptible_tries=preemptible_tries
  }

  call sfs.setFilterStatus as mergeSnvs {
    input:
    vcf=mergeScatteredSomaticSnvs.merged_vcf,
    vcf_tbi=mergeScatteredSomaticSnvs.merged_vcf_tbi,
    filtered_vcf=mergeScatteredSomaticHcSnvs.merged_vcf,
    filtered_vcf_tbi=mergeScatteredSomaticHcSnvs.merged_vcf_tbi,
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    preemptible_tries=preemptible_tries
  }

  call iv.indexVcf as indexMergedSnvs {
    input: vcf=mergeSnvs.merged_vcf,
    preemptible_tries=preemptible_tries
  }

  call sfs.setFilterStatus as mergeIndels {
    input:
    vcf=mergeScatteredSomaticIndels.merged_vcf,
    vcf_tbi=mergeScatteredSomaticIndels.merged_vcf_tbi,
    filtered_vcf=mergeScatteredSomaticHcIndels.merged_vcf,
    filtered_vcf_tbi=mergeScatteredSomaticHcIndels.merged_vcf_tbi,
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    preemptible_tries=preemptible_tries
  }

  call iv.indexVcf as indexMergedIndels {
    input: vcf=mergeIndels.merged_vcf,
    preemptible_tries=preemptible_tries
  }

  call mv.mergeVcf as merge {
    input:
    vcfs=[indexMergedSnvs.indexed_vcf, indexMergedIndels.indexed_vcf],
    vcf_tbis=[indexMergedSnvs.indexed_vcf_tbi, indexMergedIndels.indexed_vcf_tbi],
    preemptible_tries=preemptible_tries
  }

  call rvsn.replaceVcfSampleName as renameTumorSample {
    input:
    input_vcf=merge.merged_vcf,
    sample_to_replace="TUMOR",
    new_sample_name=tumor_sample_name,
    preemptible_tries=preemptible_tries
  }

  call rvsn.replaceVcfSampleName as renameNormalSample {
    input:
    input_vcf=renameTumorSample.renamed_vcf,
    sample_to_replace="NORMAL",
    new_sample_name=normal_sample_name,
    preemptible_tries=preemptible_tries
  }

  call iv.indexVcf as index {
    input: 
    vcf=renameNormalSample.renamed_vcf,
    preemptible_tries=preemptible_tries
  }

  call ff.fpFilter as filter {
    input:
    reference=reference,
    reference_fai=reference_fai,
    reference_dict=reference_dict,
    bam=tumor_bam,
    bam_bai=tumor_bam_bai,
    vcf=index.indexed_vcf,
    vcf_tbi=index.indexed_vcf_tbi,
    min_var_freq=min_var_freq,
    sample_name=tumor_sample_name,
    variant_caller="varscan",
    preemptible_tries=preemptible_tries
  }

  output {
    File unfiltered_vcf = filter.unfiltered_vcf
    File unfiltered_vcf_tbi = filter.unfiltered_vcf_tbi
    File filtered_vcf = filter.filtered_vcf
    File filtered_vcf_tbi = filter.filtered_vcf_tbi
  }
}
