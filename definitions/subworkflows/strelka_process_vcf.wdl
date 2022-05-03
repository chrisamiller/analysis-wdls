version 1.0

import "../tools/add_strelka_gt.wdl" as asg
import "../tools/bgzip.wdl" as b
import "../tools/index_vcf.wdl" as iv

workflow strelkaProcessVcf {
  input {
    File vcf
    Int preemptible_tries = 3
  }

  call asg.addStrelkaGt as addGt {
    input: 
    vcf=vcf,
    preemptible_tries=preemptible_tries
  }

  call b.bgzip {
    input: 
    file=addGt.processed_vcf,
    preemptible_tries=preemptible_tries
  }

  call iv.indexVcf as index {
    input: 
    vcf=bgzip.bgzipped_file,
    preemptible_tries=preemptible_tries
  }

  output {
    File processed_vcf = index.indexed_vcf
    File processed_vcf_tbi = index.indexed_vcf_tbi
  }
}
