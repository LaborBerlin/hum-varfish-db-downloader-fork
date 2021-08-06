rule result_noref_acmg:
    output:
        tsv="noref/acmg/v3.0/Acmg.tsv",
        release_info="noref/acmg/v3.0/Acmg.release_info",
    shell:
        r"""
                cat <<-EOF > {output.tsv}
                ensembl_gene_id    symbol    entrez_id
                ENSG00000107796    ACTA2    59
                ENSG00000159251    ACTC1    70
                ENSG00000139567    ACVRL1    94
                ENSG00000134982    APC    324
                ENSG00000084674    APOB    338
                ENSG00000123191    ATP7B    540
                ENSG00000107779    BMPR1A    657
                ENSG00000012048    BRCA1    672
                ENSG00000139618    BRCA2    675
                ENSG00000169814    BTD    686
                ENSG00000081248    CACNA1S    779
                ENSG00000118729    CASQ2    845
                ENSG00000168542    COL3A1    1281
                ENSG00000134755    DSC2    1824
                ENSG00000046604    DSG2    1829
                ENSG00000096696    DSP    1832
                ENSG00000106991    ENG    2022
                ENSG00000166147    FBN1    2200
                ENSG00000128591    FLNC    2318
                ENSG00000171298    GAA    2548
                ENSG00000102393    GLA    2717
                ENSG00000010704    HFE    3077
                ENSG00000135100    HNF1A    6927
                ENSG00000055118    KCNH2    3757
                ENSG00000282076    KCNQ1    3784
                ENSG00000053918    KCNQ1    3784
                ENSG00000130164    LDLR    3949
                ENSG00000160789    LMNA    4000
                ENSG00000125952    MAX    4149
                ENSG00000133895    MEN1    4221
                ENSG00000076242    MLH1    4292
                ENSG00000095002    MSH2    4436
                ENSG00000116062    MSH6    2956
                ENSG00000132781    MUTYH    4595
                ENSG00000134571    MYBPC3    4607
                ENSG00000133392    MYH11    4629
                ENSG00000276480    MYH11    4629
                ENSG00000092054    MYH7    4625
                ENSG00000111245    MYL2    4633
                ENSG00000160808    MYL3    4634
                ENSG00000186575    NF2    4771
                ENSG00000036473    OTC    5009
                ENSG00000083093    PALB2    79728
                ENSG00000169174    PCSK9    255738
                ENSG00000057294    PKP2    5318
                ENSG00000122512    PMS2    5395
                ENSG00000106617    PRKAG2    51422
                ENSG00000171862    PTEN    5728
                ENSG00000284792    PTEN    5728
                ENSG00000139687    RB1    5925
                ENSG00000165731    RET    5979
                ENSG00000116745    RPE65    6121
                ENSG00000196218    RYR1    6261
                ENSG00000198626    RYR2    6262
                ENSG00000183873    SCN5A    6331
                ENSG00000167985    SDHAF2    54949
                ENSG00000117118    SDHB    6390
                ENSG00000143252    SDHC    6391
                ENSG00000204370    SDHD    6392
                ENSG00000166949    SMAD3    4088
                ENSG00000141646    SMAD4    4089
                ENSG00000118046    STK11    6794
                ENSG00000106799    TGFBR1    7046
                ENSG00000163513    TGFBR2    7048
                ENSG00000135956    TMEM127    55654
                ENSG00000170876    TMEM43    79188
                ENSG00000129991    TNNI3    7137
                ENSG00000118194    TNNT2    7139
                ENSG00000141510    TP53    7157
                ENSG00000140416    TPM1    7168
                ENSG00000186439    TRDN    10345
                ENSG00000165699    TSC1    7248
                ENSG00000103197    TSC2    7249
                ENSG00000155657    TTN    7273
                ENSG00000134086    VHL    7428
                ENSG00000184937    WT1    7490
        EOF
                echo -e "table\tversion\tgenomebuild\tnull_value\nAcmg\tv3.0\t\t" > {output.release_info}
        """
