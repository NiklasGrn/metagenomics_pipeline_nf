include { MAPPING_TO_ASSEMBLY } from '../modules/local/minimap_to_assembly.nf'
include { BINNING_SEMIBIN } from '../modules/local/semibin2.nf'

include { BUSCO } from '../modules/local/busco.nf'
include { CHECKM2 } from '../modules/local/checkm2.nf'

include { KRAKEN2 as CLASSIFY_BINS } from '../modules/local/kraken2.nf'
include { MULTIQC } from '../modules/local/mulitqc.nf'

workflow BINNING_ANALYSIS {
    take:
        assembly
        reads_after_qc
        kraken_db_ch

    main:
        mapping_input_ch = assembly.join(reads_after_qc)

        MAPPING_TO_ASSEMBLY(mapping_input_ch)
        BINNING_SEMIBIN(MAPPING_TO_ASSEMBLY.out.bam_tuple)

        
        single_bins_ch = BINNING_SEMIBIN.out.bins_list.transpose()

        if (params.use_checkm2) {
            CHECKM2(single_bins_ch)
            bins = CHECKM2.out
        } else {
            BUSCO(single_bins_ch)
            bins = BUSCO.out
        }


  

        CLASSIFY_BINS(single_bins_ch, kraken_db_ch, params.out_class_bins)

        qc_reports = CLASSIFY_BINS.out.report.map{_sample_id, path -> path}.collect()
        MULTIQC(qc_reports, params.out_multiqc_binning)

    emit: 
        bins_quality = bins
}