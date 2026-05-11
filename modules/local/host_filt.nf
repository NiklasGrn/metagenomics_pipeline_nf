process HOST_FILTER {
    tag "$sample_id Host Filtered"
    label "env_mapping"
    cpus 8
    maxForks 4

    publishDir "${params.output_qc}/${stage}", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)
    path host
    val stage

    output:
    tuple val(sample_id), path("${sample_id}_host_filtered.fastq.gz")

    script:
    """
        minimap2 -ax map-ont --secondary=no -t ${task.cpus} ${host} ${reads} \
        | samtools fastq -f 4 -n -c 6 - \
        | gzip > ${sample_id}_host_filtered.fastq.gz
    """
}