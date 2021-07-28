# Download dbSNP, map chr names, normalize, and convert into TSV for import.


rule grch38_dbsnp_b155_download:
    output:
        vcf="GRCh38/dbSNP/b155/download/GCF_000001405.39.gz",
        tbi="GRCh38/dbSNP/b155/download/GCF_000001405.39.gz.tbi",
    log:
        "GRCh38/dbSNP/b155/download/GCF_000001405.39.gz.log",
    shell:
        r"""
        wget \
            -o {log} \
            -O {output.vcf} \
            ftp://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.39.gz
        wget \
            -a {log} \
            -O {output.tbi} \
            ftp://ftp.ncbi.nih.gov/snp/latest_release/VCF/GCF_000001405.39.gz.tbi

        pushd $(dirname {output.vcf})
        md5sum $(basename {output.vcf}) >$(basename {output.vcf}).md5
        md5sum $(basename {output.tbi}) >$(basename {output.tbi}).md5
        """


rule grch38_dbsnp_b155_map_chr:
    input:
        vcf="GRCh38/dbSNP/b155/download/GCF_000001405.39.gz",
        tbi="GRCh38/dbSNP/b155/download/GCF_000001405.39.gz.tbi",
    output:
        map=temp("GRCh38/dbSNP/b155/download/GCF_000001405.39.map_chr"),
        vcf="GRCh38/dbSNP/b155/download/GCF_000001405.39.map_chr.gz",
        tbi="GRCh38/dbSNP/b155/download/GCF_000001405.39.map_chr.gz.tbi",
    shell:
        r"""
        awk -v RS="(\r)?\n" 'BEGIN {{ FS="\t" }} !/^#/ {{ if ($10 != "na") print $7,$10; else print $7,$5 }}' \
            tools/data/GCF_000001405.25_GRCh37.p13_assembly_report.txt \
        > {output.map}

        bcftools annotate --threads=2 --rename-chrs {output.map} {input.vcf} -O z -o {output.vcf}
        tabix -f {output.vcf}

        pushd $(dirname {output.vcf})
        md5sum $(basename {output.vcf}) >$(basename {output.vcf}).md5
        md5sum $(basename {output.tbi}) >$(basename {output.tbi}).md5
        """


rule grch38_dbsnp_b155_normalize:
    input:
        reference="GRCh38/reference/hs38/hs38.fa",
        vcf="GRCh38/dbSNP/b155/download/GCF_000001405.39.map_chr.gz",
    output:
        vcf="GRCh38/dbSNP/b155/download/GCF_000001405.39.normalized.{chrom}.vcf.gz",
        tbi="GRCh38/dbSNP/b155/download/GCF_000001405.39.normalized.{chrom}.vcf.gz.tbi",
    shell:
        r"""
        bcftools norm \
            --check-ref s \
            --targets "{wildcards.chrom}" \
            --threads 16 \
            --multiallelics - \
            --fasta-ref {input.reference} \
            -O z \
            -o {output.vcf} \
            {input.vcf}

        tabix -f {output.vcf}
        pushd $(dirname {output.vcf})
        md5sum $(basename {output.vcf}) >$(basename {output.vcf}).md5
        """


rule result_grch38_dbsnp_b155_tsv:
    input:
        header="header/dbsnp.txt",
        vcf="GRCh38/dbSNP/b155/download/GCF_000001405.39.normalized.{chrom}.vcf.gz",
        tbi="GRCh38/dbSNP/b155/download/GCF_000001405.39.normalized.{chrom}.vcf.gz.tbi",
    output:
        release_info="GRCh38/dbSNP/b155/Dbsnp.{chrom}.release_info",
        tsv="GRCh38/dbSNP/b155/Dbsnp.{chrom}.tsv",
    shell:
        r"""
        (
            cat {input.header} | tr '\n' '\t' | sed -e 's/\t*$/\n/g';
            bcftools query {input.vcf} \
                -f 'GRCh38\t%CHROM\t%POS\t%END\t\t%REF\t%ALT\t%ID\n' \
            | sort -u -t $'\t' -k 2,2 -k 3,3 -k 6,6 -k 7,7 -S 80%
        ) \
        | python tools/ucsc_binning.py \
        > {output.tsv}

        echo -e "table\tversion\tgenomebuild\tnull_value\nDbsnp\tb155\tGRCh38\t" > {output.release_info}
        """