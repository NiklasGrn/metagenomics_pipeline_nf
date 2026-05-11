process CHECKM2 {
    tag "checkm2 ${sample_id}"
    label "env_binning"
    publishDir "${params.outdir}/${params.out_class_bins_qc}", mode: 'copy'
    maxForks 4
    errorStrategy 'ignore'

    // conda '/home/ngrundner/miniforge3/envs/checkm2'

    input:
    tuple val(sample_id), path(bins)

    output:
    path "${bins.simpleName}"

    script:
    """
    checkm2 predict -i ${bins} -o ${bins.simpleName} 
    """
}