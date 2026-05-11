process MAPPING_TO_REF {
    tag "Mapping reference ${sample_id}"
    label "env_mapping"
    publishDir "${params.outdir}/${params.out_mapping_ref}", mode: 'copy'
    cpus 8

    input:
    tuple val(sample_id), path(reads)
    path ref

    output:
    tuple val(sample_id), path("${sample_id}.bam"), path("${sample_id}.tsv"), emit: mapping_ref_tuple

    script:
    """
    minimap2 -d referenz_index.mmi ${ref}

    minimap2 -ax map-ont -t ${task.cpus} referenz_index.mmi ${reads} \
    | samtools sort -o ${sample_id}.bam

    
    samtools idxstats ${sample_id}.bam > ${sample_id}.tsv
    """
}