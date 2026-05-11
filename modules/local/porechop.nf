process PORECHOP {
    tag "$sample_id Adapter Trimming"
    label "env_porechop"
    cpus 8

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_porechop.fastq")

    script:
    """
    porechop -i ${reads} -o ${sample_id}_porechop.fastq
    """
}