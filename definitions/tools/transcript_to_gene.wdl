version 1.0

task transcriptToGene {
  input {
    File gene_transcript_lookup_table
    File transcript_table_h5
    Int preemptible_tries = 3
  }

  Int space_needed_gb = 10 + round(size([transcript_table_h5, gene_transcript_lookup_table], "GB"))
  runtime {
    preemptible: preemptible_tries
    memory: "2GB"
    cpu: 1
    docker: "mgibio/rnaseq:1.0.0"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  command <<<
    /usr/local/bin/Rscript /usr/src/transcript_to_gene.R \
        ~{gene_transcript_lookup_table} ~{transcript_table_h5}
  >>>

  output {
    File gene_abundance = "gene_abundance.tsv"
  }
}
