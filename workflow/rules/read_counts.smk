import os

if config["count_duplicates"] == True:
    remove_flag = ""
else:
    remove_flag = "--ignoreDup"

# Define the rule to count reads per feature
rule read_counts:
    input:
        fasta = lambda wildcards: os.path.join(ori_genome_dir, genome[genome_name[wildcards.sample]]),
        anno = lambda wildcards: os.path.join(ori_genome_dir, gff[genome_name[wildcards.sample]]),
        bam = lambda wildcards: "results/3-noduplicates/{sample}.dedup.bam" if config["flag_dup"] else "results/2-map_reads/{sample}.Aligned.sortedByCoord.out.bam"
    output:
        gtf = "results/4-counts/{sample}.gtf",
        counts = "results/4-counts/{sample}_read_counts",
        summary = "results/4-counts/{sample}_read_counts.summary"
    params:
        feat_counts_param = config['feat_counts_param'],
        remove_flag = remove_flag
    benchmark:
        "benchmarks/4-counts/{sample}_counts.tsv"
    threads: 16
    resources:
        cpus_per_task = 16,
        partition = "norm",
        time = "14:00:00",
        mem_mb = 32000
    log:
        logfile = "logs/4-counts/{sample}_featureCounts.log"
    shell:
        """
        module load subread/2.0.6

        gffread {input.anno} -T -F -o {output.gtf}

        featureCounts {params.feat_counts_param} {params.remove_flag} -G {input.fasta} -T {threads}\
         -a {output.gtf} \
         -o {output.counts} {input.bam} > {log.logfile} 2>&1
        """
