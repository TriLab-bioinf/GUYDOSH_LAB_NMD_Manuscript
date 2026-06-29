# Map reads to reference with STAR

# Set STARdb path and check if STARdb already exists, otherwise create one
# Make STARdb

rule make_star_db:
    input:
        fasta = lambda wildcards: os.path.join(ori_genome_dir, genome[wildcards.genome_name]),
        anno = lambda wildcards: os.path.join(ori_genome_dir, gff[wildcards.genome_name])
    output:
        db = os.path.join(genome_dir, "{genome_name}/SA")
    resources:
        mem_mb = 1024 * 64,
        partition = "norm",
        runtime = 48 * 60,
        disk_mb = 1024 * 20
    threads: 16
    params:
        so = f"{stardb_overhang}",
        index = lambda wildcards: os.path.join(genome_dir, wildcards.genome_name),
        tmp = lambda wildcards: os.path.join(genome_dir, wildcards.genome_name,"_STARtmp")
    shell:
        """
        module load STAR/2.7.11b

        mkdir -p {params.index} 

        STAR --runMode genomeGenerate \
             --genomeDir {params.index} \
             --genomeFastaFiles {input.fasta} \
             --sjdbGTFfile {input.anno} \
             --runThreadN {threads} \
             --outTmpDir {params.tmp} \
             --sjdbOverhang {params.so}
        touch {output.db}  
        """

rule map_reads:
    input:
        fq1 = lambda wildcards: [f"results/1-trim/{wildcards.sample}.P.R1.fastq.gz" if (config["trimming"] == True) else f"data/reads/{fq_1[wildcards.sample]}"],
        fq2 = lambda wildcards: [f"results/1-trim/{wildcards.sample}.P.R2.fastq.gz" if (config["trimming"] == True) else f"data/reads/{fq_2[wildcards.sample]}"],
        star_db = lambda wildcards: os.path.join(genome_dir, genome_name[wildcards.sample],"SA")
    output:
        bam = "results/2-map_reads/{sample}.Aligned.sortedByCoord.out.bam",
        bai = "results/2-map_reads/{sample}.Aligned.sortedByCoord.out.bam.bai"
    threads: 8
    resources:
        partition = "norm",
        runtime = 14 * 60,
        mem_mb = 1024 * 64,
        disk_mb = 1024 * 20
    benchmark:
        "benchmarks/2-map_reads/{sample}.star.tsv"
    params:
        stardb_dir = lambda wildcards: os.path.join(genome_dir, genome_name[wildcards.sample]),
        prefix = "results/2-map_reads/{sample}."
    log:
        logfile = "logs/2-map_reads/{sample}.star.log"
    shell:
        """
        module load STAR/2.7.11b samtools/1.21
            
        STAR --runMode alignReads \
             --runThreadN {threads} \
             --genomeDir {params.stardb_dir} \
             --alignSJDBoverhangMin 1 \
             --alignSJoverhangMin 5 \
             --outFilterMismatchNmax 2 \
             --alignEndsType EndToEnd \
             --readFilesIn {input.fq1} {input.fq2} \
             --readFilesCommand zcat \
             --outFileNamePrefix {params.prefix} \
             --quantMode GeneCounts \
             --outSAMtype BAM SortedByCoordinate \
             --outSAMattrRGline ID:$ SM:{wildcards.sample} PL:ILLUMINA \
             --outSAMattributes All > {log.logfile} 2>&1

        samtools index -@ 8 {output.bam} >> {log.logfile} 2>&1
        """