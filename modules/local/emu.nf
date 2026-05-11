process EMU {
    tag "emu ${input_file.simpleName}"
    label "env_emu"
    
    publishDir "${params.outdir}/${params.out_class_reads}", mode: 'copy'
    cpus 16
    maxForks 3

    input:
    tuple val(sample_id), path(input_file)
    path db_dir

    output:
    tuple val(sample_id), path("*.tsv"), emit: report
    path "*" 

    script:
    """   
    emu abundance ${input_file} --db ${db_dir} --threads ${task.cpus} --keep-counts --output-dir . --output-unclassified --min-abundance 0.000001 --max-align-len 2500
    """
}