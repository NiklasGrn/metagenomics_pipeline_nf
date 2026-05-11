process KRAKEN2 {
    tag "Kraken ${input_file.simpleName}"
    label "env_tax"
    
    publishDir "${params.outdir}/${stage}", mode: 'copy'
    cpus 8
    maxForks 3

    input:
    tuple val(sample_id), path(input_file)
    path db_dir
    val stage

    output:
    tuple val(sample_id), path("${input_file.simpleName}_report.txt"), emit: report
    tuple val(sample_id), path("${input_file.simpleName}.txt"), emit: output
    


    script:
    """   
    kraken2 --db ${db_dir} \
            --threads ${task.cpus} \
            --report ${input_file.simpleName}_report.txt \
            --output ${input_file.simpleName}.txt \
            --use-names \
            ${input_file}
    """
}