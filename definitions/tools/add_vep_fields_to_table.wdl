version 1.0

task addVepFieldsToTable {
  input {
    File vcf
    Array[String] vep_fields = ["Consequence", "SYMBOL", "Feature", "HGVSc", "HGVSp"]
    File? tsv
    String prefix = "variants"
  }

  runtime {
    memory: "4GB"
    docker: "griffithlab/vatools:4.1.0"
  }

  command <<<
    vep-annotation-reporter -o ~{prefix}.annotated.tsv \
    ~{vcf} ~{sep=" " vep_fields} \
    ~{if defined(tsv) then "-t ~{tsv}" else ""}
  >>>

  output {
    File annotated_variants_tsv = "~{prefix}.annotated.tsv"
  }
}

workflow wf {
  input {
    File vcf
    Array[String]? vep_fields
    File? tsv
    String? prefix
  }

  call addVepFieldsToTable {
    input:
    vcf=vcf,
    vep_fields=vep_fields,
    tsv=tsv,
    prefix=prefix
  }
}