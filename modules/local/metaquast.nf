process METAQUAST {
    tag "MetaQUAST"
    label "env_metaquast"
    publishDir "${params.outdir}/MetaQUAST", mode: 'copy'
    cpus 8 
    memory '32 GB'

    input:
    path contigs

    output:
    path "combined_report/*", emit: metaquast_report

    script:
    """
    metaquast.py -t ${task.cpus} -R ${params.host_ref} -o combined_report/ ${contigs}
    """
}