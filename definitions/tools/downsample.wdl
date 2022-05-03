version 1.0

task downsample {
  input {
    File sam
    Float probability
    File reference
    File reference_fai
    File reference_dict
    Int? random_seed
    String? strategy  # enum [HighAccuracy, ConstantMemory, Chained]
    Int preemptible_tries = 3
  }

  Float reference_size = size([reference, reference_fai, reference_dict], "GB")
  Int space_needed_gb = 10 + round(reference_size + size(sam, "GB") * 2)
  runtime {
    preemptible: preemptible_tries
    memory: "18GB"
    docker: "broadinstitute/gatk:4.1.4.1"
    disks: "local-disk ~{space_needed_gb} SSD"
  }

  String outfile = basename(basename(sam, ".sam"), ".cram")
  command <<<
    /gatk/gatk --java-options -Xmx16g DownsampleSam \
    --OUTPUT=~{outfile}.bam --CREATE_INDEX --CREATE_MD5_FILE \
    --INPUT="~{sam}" --PROBABILITY=~{probability} --REFERENCE_SEQUENCE="~{reference}" \
    ~{if defined(random_seed) then "--RANDOM_SEED=" + random_seed else ""} \
    ~{if defined(strategy) then "--STRATEGY=" + strategy else ""}
  >>>

  output {
    File downsampled_sam = outfile + ".bam"
    File downsampled_sam_md5 = outfile + ".bam.md5"
    File downsampled_sam_bai = outfile + ".bai"
  }
}
