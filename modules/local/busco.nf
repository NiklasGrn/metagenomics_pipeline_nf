process BUSCO {
    tag "busco ${sample_id}"
    // label "env_binning"
    publishDir "${params.outdir}/${params.out_class_bins_qc}", mode: 'copy'
    maxForks 4
    errorStrategy 'ignore'

    conda 'bioconda::busco=5.8.0'

    input:
    tuple val(sample_id), path(bins)

    output:
    path "${bins.simpleName}"

    script:
    """
    busco -i ${bins} -o ${bins.simpleName} -m genome --auto-lineage
    """
}