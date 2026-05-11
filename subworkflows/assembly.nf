include { ASSEMBLY as ASSEMBLY_FLYE } from '../modules/local/metaflye.nf'
include { ASSEMBLY as ASSEMBLY_RAVEN } from '../modules/local/raven.nf'
include { POLISHING } from '../modules/local/medaka.nf'
include { METAQUAST } from '../modules/local/metaquast.nf'


include { MAPPING_TO_REF } from '../modules/local/minimap_ref.nf'

include { KRAKEN2 as CLASSIFY_READS } from '../modules/local/kraken2.nf'
include { MULTIQC as MULTIQC_READS } from '../modules/local/mulitqc.nf'
include { KRONA as KRONA_READS } from '../modules/local/krona.nf'

include { BRACKEN_CLASSIFY } from '../modules/local/bracken.nf'

include { KRAKEN2 as CLASSIFY_ASSEMBLY } from '../modules/local/kraken2.nf'
include { MULTIQC as MULTIQC_ASSEMBLY } from '../modules/local/mulitqc.nf'
include { KRONA as KRONA_ASSEMBLY } from '../modules/local/krona.nf'

workflow ASSEMBLY_CLASSIFICATION {
    take:
        qc_reads
        kraken_db_ch
    
    main:
        CLASSIFY_READS(qc_reads, kraken_db_ch, params.out_class_reads)
        report_reads = CLASSIFY_READS.out.report.map{_sample_id, path -> path}.collect()
        MULTIQC_READS(report_reads, params.out_multiqc_reads)
        KRONA_READS(CLASSIFY_READS.out.report, params.out_class_reads, "reads")
        if (params.map_to_ref && params.ref) { 
            MAPPING_TO_REF(qc_reads, params.ref) 
        }

        BRACKEN_CLASSIFY(CLASSIFY_READS.out.report, kraken_db_ch, 300)

        if (params.skip_assembly) {
            polished_assembly = null
            reads_classified = CLASSIFY_READS.out.report
        } else {       
        
            if (params.tool == "flye") {
                ASSEMBLY_FLYE(qc_reads)
                assemblies_ch = ASSEMBLY_FLYE.out.contigs
            } else if (params.tool == "raven") {
                ASSEMBLY_RAVEN(qc_reads)
                assemblies_ch = ASSEMBLY_RAVEN.out.raven_contigs
            } else {
                error "Unsupported assembly tool: ${params.tool}. Use 'flye' or 'raven'."
            }

            ch_for_polishing = assemblies_ch.join(qc_reads)

            POLISHING(ch_for_polishing)


            if (params.host_ref) {
                all_polished_files = POLISHING.out.polished_assembly
                    .map { _sample_id, fasta -> fasta }
                    .collect()
                METAQUAST(all_polished_files)
            }

            CLASSIFY_ASSEMBLY(POLISHING.out.polished_assembly, kraken_db_ch, params.out_class_assembly)
            reports_assembly = CLASSIFY_ASSEMBLY.out.report.map{_sample_id, path -> path}.collect()

            MULTIQC_ASSEMBLY(reports_assembly, params.out_multiqc_assembly)
            KRONA_ASSEMBLY(CLASSIFY_ASSEMBLY.out.report, params.out_class_assembly, "assembly")
            
            polished_assembly = POLISHING.out.polished_assembly
            reads_classified = CLASSIFY_READS.out.report

        }

    emit:
        polished_assembly = polished_assembly
        reads_classified = reads_classified
}

