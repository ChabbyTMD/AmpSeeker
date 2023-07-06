from snakemake.utils import validate
import pandas as pd

# Split into two sample sets as bcftools merge cant take over 1000 files
# So we must do two rounds of merging
if len(metadata) > 1000:
    large_sample_size = True
    n_samples = len(metadata)
    half = int(n_samples/2)
    samples1 = metadata['sampleID'][:half]
    samples2 = metadata['sampleID'][half:]
else:
    large_sample_size = False
    samples1 = []
    samples2 = []

rule set_kernel:
    input:
        f'{workflow.basedir}/envs/AmpSeeker-python.yaml'
    output:
        touch("results/.kernel.set")
    conda: f'{workflow.basedir}/envs/AmpSeeker-python.yaml'
    log:
        "logs/set_kernel.log"
    shell: 
        """
        python -m ipykernel install --user --name=AmpSeq_python 2> {log}
        """





def AmpSeekerOutputs(wildcards):
    inputs = []
    if config['bcl-convert']:
        inputs.extend(["results/index-read-qc/I1.html", "results/index-read-qc/I2.html"])

    if plate_info:
        inputs.extend(["results/notebooks/reads-per-well.ipynb", 
                        "docs/ampseeker-results/notebooks/reads-per-well.ipynb"])
 
    if large_sample_size:
        inputs.extend(expand("results/vcfs/{dataset}.complete.merge_vcfs", dataset=config['dataset']))
    else:
        inputs.extend(expand("results/vcfs/{dataset}.merged.vcf", dataset=config['dataset']))

    if config['quality-control']['coverage']:
            inputs.extend(
                expand(
                    [
                        "results/coverage/{sample}.per-base.bed.gz",
                        "results/notebooks/coverage.ipynb",
                        "docs/ampseeker-results/notebooks/coverage.ipynb"
                    ],
                sample=samples)
                )

    if config['quality-control']['fastp']:
        inputs.extend(
            expand(
                [
                    "results/fastp_reports/{sample}.html",
                ],
                sample=samples,
            )
        )   

    if config['quality-control']['qualimap']:
        inputs.extend(               
            expand(
                [
                    "results/qualimap/{sample}",
                ],
                sample=samples,
            )
        )
    
    if config['quality-control']['multiqc']:
        inputs.extend(
            expand(
                [
                    "results/multiqc/multiqc_report.html",
                ],
            )
        )
    
    if config['quality-control']['stats']:
        inputs.extend(
            expand(
                [
                    "results/alignments/bamStats/{sample}.flagstat",
                    "results/vcfs/stats/{dataset}.merged.vcf.txt",
                ],
                sample=samples, 
                dataset=config['dataset'],
            )
        )

    if config['analysis']['pca']['activate']:
        inputs.extend(
            expand(
                [
                    "results/notebooks/principal-component-analysis.ipynb",
                    "docs/ampseeker-results/notebooks/principal-component-analysis.ipynb"
                ],
            )
        )

    if config['analysis']['allele-frequencies']['activate']:
        inputs.extend(
            expand(
                [
                    "results/notebooks/allele-frequencies.ipynb",
                    "docs/ampseeker-results/notebooks/allele-frequencies.ipynb"
                ],
            )
        )

    if config['analysis']['sample-map']:
        inputs.extend(
            expand(
                [
                    "results/notebooks/sample-map.ipynb",
                    "docs/ampseeker-results/notebooks/sample-map.ipynb"
                ],
            )
        )

    if config['analysis']['igv']:
        inputs.extend(
            [
                "results/notebooks/IGV-explore.ipynb",
                "docs/ampseeker-results/notebooks/IGV-explore.ipynb"
            ]
            )

    if config['build-jupyter-book']:
        inputs.extend(["results/ampseeker-results/_build/html/index.html"])
    
    return inputs

