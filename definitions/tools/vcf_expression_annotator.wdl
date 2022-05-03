version 1.0

task vcfExpressionAnnotator {
  input {
    File vcf
    File expression_file
    String expression_tool
    String data_type
    String sample_name
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(2*size([vcf, expression_file], "GB"))
  runtime {
    preemptible: preemptible_tries
    docker: "griffithlab/vatools:4.1.0"
    memory: "4GB"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = "annotated.expression.vcf.gz"
  command <<<
    vcf-expression-annotator -o ~{outfile} \
    ~{vcf} \
    ~{expression_file} \
    ~{expression_tool} \
    ~{data_type} \
    -s ~{sample_name}
  >>>

  output {
    File annotated_expression_vcf = outfile
  }
}

workflow wf {
  input {
    File vcf
    File expression_file
    String expression_tool
    String data_type
    String sample_name
    Int preemptible_tries = 3
  }
  call vcfExpressionAnnotator {
    input:
    vcf=vcf,
    expression_file=expression_file,
    expression_tool=expression_tool,
    data_type=data_type,
    sample_name=sample_name,
    preemptible_tries=preemptible_tries
  }
}
