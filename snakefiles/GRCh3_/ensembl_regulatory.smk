rule grchxx_ensembl_regulatory_download:
    output:
        tsv="{genome_build}/ensembl_regulatory/{download_date}/download/EnsemblRegulatoryFeature.tsv",
    shell:
        r"""
        if [[ {wildcards.genome_build} == GRCh37 ]]; then
            prefix=grch37.
        else
            prefix=
        fi

        echo -e "Chromosome/scaffold name\tStart (bp)\tEnd (bp)\tRegulatory stable ID\tFeature type\tFeature type description\tSO term accession\tSO term name" \
        > {output.tsv}
        wget -O - 'http://grch37.ensembl.org/biomart/martservice?query=<?xml version="1.0" encoding="UTF-8"?> <!DOCTYPE Query> <Query  virtualSchemaName = "default" formatter = "TSV" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" > <Dataset name = "hsapiens_regulatory_feature" interface = "default" > <Attribute name = "chromosome_name" /> <Attribute name = "chromosome_start" /> <Attribute name = "chromosome_end" /> <Attribute name = "regulatory_stable_id" /> <Attribute name = "feature_type_name" /> <Attribute name = "feature_type_description" /> <Attribute name = "so_accession" /> <Attribute name = "epigenome_name" /> <Attribute name = "epigenome_description" /> <Attribute name = "efo_id" /> </Dataset> </Query>' \
        | grep '^[0-9XYM]' \
        | LC_ALL=C sort -k1,1g -k2,2n -k3,3n \
        >> {output.tsv}
        """


rule result_grchxx_ensembl_regulatory_tsv:
    input:
        tsv="{genome_build}/ensembl_regulatory/{download_date}/download/EnsemblRegulatoryFeature.tsv",
        header="header/ensembl_regulatory.txt",
    output:
        tsv="{genome_build}/ensembl_regulatory/{download_date}/EnsemblRegulatoryFeature.tsv",
        release_info="{genome_build}/ensembl_regulatory/{download_date}/EnsemblRegulatoryFeature.release_info",
    wildcard_constraints:
        download_date="[^/]+",
    shell:
        r"""
        (
            cat {input.header} | tr '\n' '\t' | sed -e 's/\t*$/\n/g';
            tail -n +2 {input.tsv} \
            | awk -F$"\t" 'BEGIN{{OFS=FS}}{{$1="{wildcards.genome_build}\t"$1; $3=$3"\t"; print}}'
        ) \
        | python tools/ucsc_binning.py \
        > {output.tsv}

        echo -e "table\tversion\tgenomebuild\tnull_value\nEnsemblRegulatoryFeature\t{wildcards.download_date}\t{wildcards.genome_build}\t" > {output.release_info}
        """
