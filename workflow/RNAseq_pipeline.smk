# RNAseq  processing pipeline single-end workflow v2.0
# Hernan Lorenzi
# hernan.lorenzi@nih.gov
# Workflow asumes reads are already trimmed and deduplicated (based on UMIs) 
# Workflow requires to configure the config.yml file accordingly to include all metadatata required.

import os
import glob
import pandas as pd

# Read config file
configfile: "./config/config.yaml"
#annotation: str = config["reference"]["gtf"]
adapters: str = config["adapters"]
#genome: str = config["reference"]["fasta"]
#stardb_path: str = config["stardb"]["path"]
stardb_overhang: str = config["stardb"]["sjdbOverhang"]
reads_dir: str = config["reads"]
ori_genome_dir: str = config["genome"]
genome_dir: str = config["genome_dir"]

# Read sample data from samplesheet and skip comments
metadata = pd.read_csv(config["metadata"], comment='#', sep=',', header=0, dtype=str)

# Create dictionaries from metadata for @RG line
# metadata is imported from ./config/samplesheet.csv file
fq_1: dict = {s:fq1 for s, fq1 in zip(metadata['sample_ID'], metadata['fastq_1'])}
fq_2: dict = {s:fq2 for s, fq2 in zip(metadata['sample_ID'], metadata['fastq_2'])}
#genome: dict = {s:genome for s, genome in zip(metadata['sample_ID'], metadata['genome'])}
#gff: dict = {s:gff for s, gff in zip(metadata['sample_ID'], metadata['gff'])}
genome: dict = {gname:genome for gname, genome in zip(metadata['genome_name'], metadata['genome'])}
gff: dict = {gname:gff for gname, gff in zip(metadata['genome_name'], metadata['gff'])}
genome_name: dict = {s:genome_name for s, genome_name in zip(metadata['sample_ID'], metadata['genome_name'])}
samples: list = list(metadata['sample_ID'])


os.makedirs(genome_dir, exist_ok=True)


# Set what rules to run locally
localrules: all 

rule all:
    # IMPORTANT: output file for all rules has to match the name specified in the output file
    # and not include suffixes that the command use might add to it.
    input: 
        expand(os.path.join(genome_dir, "{genome_name}/SA"), genome_name=genome_name.values()),
        "results/6-multiqc/multiqc_report.html"


if config["trimming"] == True:
    trim_output = "results/1-trimming"
    # 1- Trim reads with fastp
    include: "rules/trim_reads.smk"
else:
    trim_output = "data/reads"


# 2- Map trimmed reads to reference with bwa-mem2
include: "rules/map_reads.smk"

if config["flag_dup"] == True:
    # 3- Flag duplicated reads with GATK MarkDuplicates
    include: "rules/mark_duplicates.smk"

# 4- Count reads per feature with featureCounts
include: "rules/read_counts.smk"

# 5- Make bigwig files from bam files
include: "rules/make_bigwig.smk"

# 6- Run multiqc report
include: "rules/multiqc.smk"