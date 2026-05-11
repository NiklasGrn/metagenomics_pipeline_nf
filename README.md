# NiklasGrn/metagenomics_pipeline

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A525.10.4-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)


## Introduction

**NiklasGrn/metagenomics_pipeline** is a bioinformatics pipeline that used in the writing of the thesis "Comparison of Adaptive Sampling and Biochemical Host Depletion Strategies for Whole Genome Shotgun Sequencing and 16S Nanopore Metagenomics Workflows" by Niklas Grundner at the Hochschule Campus Wien, University of Applied Sciences.


## Prerequisites

- Nextflow >= 20.10.0
- Conda
- Krona Tools (difficulty to install via Conda, so install separately if needed)
- Reference databases (Kraken2, Bracken, EMU) configured in `nextflow.config` (can also be set via commandline as written in Advanced Options, configure in `nextflow.config` is recommended)


## Usage

> [!NOTE]
> If you are new to Nextflow, please refer to [this page](https://nf-co.re/docs/get_started/environment_setup/nextflow) on how to set-up Nextflow.

### Basic Usage

```bash
nextflow run main.nf
```

By default, the pipeline will:
1. Process FASTQ files from `data/*.fastq.gz`
2. Perform quality control (adapter trimming, quality filtering)
3. Assemble the filtered reads
4. Classify the reads and assembly
5. Generate binning analysis and quality control reports

## Input Data

Place your compressed FASTQ files in the `data/` directory:

```bash
data/sample1.fastq.gz
data/sample2.fastq.gz
```

To use a different input directory or pattern, specify the `reads` parameter:

```bash
nextflow run main.nf --reads "my_data/*.fastq.gz"
```

## Output Structure

Results are organized in the `results/` directory:

```
results/
├── 01_raw_nanoplot/              # Raw read QC plots
├── 02_filtered_reads/            # Quality-filtered reads
├── 03_host_removed_reads/        # After host depletion (if enabled)
├── 04_human_removed_reads/       # After human depletion (if enabled)
├── 05_filtered_nanoplot/         # Filtered read QC plots
├── 11_assembly/                  # Assembled contigs/genomes
├── 12_polishing/                 # Polished assemblies
├── 13_binning/                   # Metagenomic bins
├── 21_classified_reads/          # Read classification results
├── 22_classified_bracken/        # Bracken abundance estimates
├── 23_classified_assembly/       # Assembly classification
├── 24_classified_bins/           # Bin classification
├── 25_classified_bins_qc/        # Bin quality metrics
├── 26_mapping_to_reference/      # Reference mapping results
├── 31_multiqc_qc/                # QC report
├── 32_multiqc_reads_classification/   # Read classification report
├── 33_multiqc_assembly_classification/ # Assembly report
└── 34_multiqc_binning_classification/  # Binning analysis report
```

To specify a different output directory:

```bash
nextflow run main.nf --outdir "my_results"
```

## Bioconda Tool Versions

| Environment | Bioconda Packages |
|-------------|-------------------|
| Taxonomy/classification | `kraken2=2.17.1`, `bracken=3.1` |
| Krona | `krona=2.8.1` |
| Binning | `checkm2=1.1.0` |
| Assembly QC | `quast=5.3.0` |
| MultiQC | `multiqc=1.33` |
| Adapter trimming | `porechop=0.2.4` |
| Assembly | `flye=2.9.1`, `raven-assembler=1.8.3` |
| Polishing | `medaka=2.2.0` |
| Plotting | `nanoplot=1.46.2` |
| Mapping | `minimap2=2.30` |
| EMU 16S | `emu=3.6.2` |
| Filtering | `nanofilt=2.8.0` |
| SemiBin | `semibin=2.2.1` |


## Advanced Options

### Resume Failed Runs

Resume a pipeline run from the last successful checkpoint:

```bash
nextflow run main.nf -resume
```

### Classification Mode

Choose between 16S rRNA classification or metagenomic assembly and classification:
16S classification with EMU (`--classify_16S` default: false)


```bash
nextflow run main.nf --classify_16S true

nextflow run main.nf --classify_16S false
```

### Quality Control Parameters

Configure read filtering thresholds:
Minimum Quality `--min_q` default: 10   Minimum Length  `--min_q` default: 1000

```bash
nextflow run main.nf --min_q 12

nextflow run main.nf --min_len 2000
```

### Host/Contaminant Removal

Remove host organism reads:

```bash
nextflow run main.nf --host_depletion true

nextflow run main.nf --host_depletion true --host_ref "/path/to/host_genome.fa"
```

Remove human contamination:

```bash
nextflow run main.nf --human_depletion true
```

### Skip Steps

Skip specific analysis stages:

```bash
nextflow run main.nf --skip_binning true

nextflow run main.nf --skip_assembly true
```

### Mapping to Reference

Classify reads by mapping to a reference database:

```bash
nextflow run main.nf --map_to_ref true --ref "/path/to/reference.fasta"
```

## Configuration

For frequently used parameter sets, edit `nextflow.config` directly:

```groovy
params {
    reads = "data/*.fastq.gz"
    min_q = 12
    min_len = 2000
    host_depletion = true
    tool = "flye"
}
```

Or create a custom configuration file:

```bash
nextflow run main.nf -c custom.config
```

### Database Configuration

Specify custom database locations:

```bash
nextflow run main.nf --kraken_db "/path/to/kraken2_db"

nextflow run main.nf --bracken_db_files "/path/to/bracken_db"

nextflow run main.nf --emu_db "/path/to/emu_silva"
```

## Execution Profiles

Use predefined profiles for specific database configurations:
Use the NT core database (nucleotide core collection only 1 simultaneous process of Kraken2 and additional CPU usage allocated)

```bash
nextflow run main.nf -profile nt_core
```



## Troubleshooting

### Out of memory errors

Adjust executor resources in `nextflow.config`:

```groovy
executor {
    cpus = 32
    memory = '200 GB'
}
```



## Credits

NiklasGrn/metagenomics_pipeline was originally written by Niklas Grundner.

