nextflow.enable.dsl=2

include { QC_READS } from './subworkflows/qc_reads.nf'
include { ASSEMBLY_CLASSIFICATION } from './subworkflows/assembly.nf'
include { BINNING_ANALYSIS } from './subworkflows/binning_analysis.nf'
include { EMU } from './modules/local/emu.nf'



workflow {
    reads_ch = channel.fromPath(params.reads).map{file -> tuple(file.simpleName, file)}
    kraken_db_ch = channel.value(file(params.kraken_db))
    emu_db_ch = channel.value(file(params.emu_db))
    
    // QC used for all samples
    reads_after_qc = QC_READS(reads_ch)

    // 16S Classification if specified, otherwise Assembly + Classification + Binning
    if (params.classify_16S) {
        EMU(reads_after_qc, emu_db_ch)
    } else {

        //Assembly + Classification
        assembly = ASSEMBLY_CLASSIFICATION(reads_after_qc, kraken_db_ch)

        // Binning + Analysis
        if (!params.skip_binning || !params.skip_assembly) {
            BINNING_ANALYSIS(assembly.polished_assembly, reads_after_qc, kraken_db_ch)
        }
    }
}