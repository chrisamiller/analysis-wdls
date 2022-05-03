version 1.0

import "../tools/bgzip.wdl" as b
import "../tools/index_vcf.wdl" as i

workflow bgzipAndIndex {
  input {
    File vcf
    Int preemptible_tries = 3
  }

  call b.bgzip {
    input: 
    file=vcf,
    preemptible_tries=preemptible_tries  

  }

  call i.indexVcf as index {
    input: 
    vcf=bgzip.bgzipped_file,
    preemptible_tries=preemptible_tries  
  }

  output {
    File indexed_vcf = index.indexed_vcf
    File indexed_vcf_tbi = index.indexed_vcf_tbi
  }
}
