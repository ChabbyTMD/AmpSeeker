
rule coverage:
    input:
        nb = f"{workflow.basedir}/notebooks/coverage.ipynb",
        kernel = "results/.kernel.set",
        per_base = expand("results/coverage/{sample}.per-base.bed.gz", sample=samples),
        metadata = config["metadata"],
        targets = config['targets'],
    output:
        nb = "results/notebooks/coverage.ipynb",
        docs_nb = "docs/ampseeker-book/notebooks/coverage.ipynb"
    conda:
        "../envs/AmpSeeker-python.yaml"
    log:
        "logs/notebooks/coverage.log"
    shell:
        """
        papermill {input.nb} {output.nb} -k AmpSeq_python -p metadata_path {input.metadata} -p bed_targets_path {input.targets} 2> {log}
        cp {output.nb} {output.docs_nb} 2>> {log}
        """

rule igv_notebook:
    input:
        nb = f"{workflow.basedir}/notebooks/IGV-explore.ipynb",
        kernel = "results/.kernel.set",
        alignments = expand("results/alignments/{sample}.bam", sample=samples),
        genome = config["reference_fasta"],
        index = config["reference_fasta"] + ".fai",
        gff3 = config["reference_gff3"],
        metadata = config["metadata"],
    output:
        nb = "results/notebooks/IGV-explore.ipynb",
        docs_nb = "docs/ampseeker-book/notebooks/IGV-explore.ipynb"
    conda:
        "../envs/AmpSeeker-python.yaml"
    log:
        "logs/notebooks/IGV-explore.log"
    params:
        reference_name = config["reference_name"],
    shell:
        """
        papermill {input.nb} {output.nb} -k AmpSeq_python -p metadata_path {input.metadata} -p genome_name {params.reference_name} -p reference_fasta {input.genome} -p reference_gff3 {input.gff3} 2> {log}
        cp {output.nb} {output.docs_nb} 2>> {log}
        """