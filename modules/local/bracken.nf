process BRACKEN_CLASSIFY {
    tag "Bracken classify ${sample_id}"
    label "env_tax"
    publishDir "${params.outdir}/${params.out_class_bracken}", mode: 'copy'
    cpus 8

    input:
    tuple val(sample_id), path(kraken_report)
    path bracken_db_files
    val length

    output:
    tuple val(sample_id), path("${sample_id}_report.bracken"), emit: bracken_abundance
    tuple val(sample_id), path("${sample_id}.report"), emit: bracken_report

    script:
    """   
    bracken -d ${bracken_db_files} \
            -i ${kraken_report} \
            -o ${sample_id}_report.bracken \
            -r ${length} -l S \
            -w ${sample_id}.report \
            -t ${task.cpus}
    """
}