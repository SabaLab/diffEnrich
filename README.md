
<!-- README.md is generated from README.Rmd. Please edit that file -->
diffEnrich
==========

The goal of diffEnrich is simple. Given a list of gene symbols, *diffEnrich* will perform differential enrichment ananlysis using the Kyoto Encyclopedia of Genes and Genomes (KEGG) REST API. This package provides a number of functions that are intended to be used in a pipeline (See Figure N). Breifly, the workflow will download and clean species specific ENTREZ gene IDs and map them to their respective KEGG pathways by accessing KEGG's REST API. This way the user will always have the most up-to-date pathway data from KEGG. Next, the user will identify significantly enriched pathways from two different gene sets, and finally, the user will identify pathways that are differentially expressed between the two gene sets. In addition to the analysis pipeline, this package also provides functions for data visualizations.

development of methods and software for differential enrichment analysis

Papers from Saba Lab where differentially enrichment has been used: 1. [Shearn et al 2018 - ACER](https://onlinelibrary.wiley.com/doi/full/10.1111/acer.13766)

Installation
------------

You can install the released version of diffEnrich from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("diffEnrich")
```

Example
-------

### Step 1: Collect and clean pathways from KEGG API

First we will use the *get\_kegg* function access the KEGG REST API and download the data sets required to perform our downstream analysis. This function takes two arguments. The first, 'species' is required and is the species of interest. Currently, *diffEnrich* supports three species, and the argument is a character string using the KEGG code [REF](https://www.pnas.org/content/suppl/2008/09/11/0806162105.DCSupplemental/ST1_PDF.pdf): Homo sapiens (human), use 'hsa'; Mus musculus (mouse), use 'mmu', and Rattus norvegicus (rat), use 'rno'. The second, 'path' is also passed as a character string, and is the path of the directory in which the user would like to write the data sets downloaded from the KEGG REST API. If the user does not provide a path, the data sets will be automatically written to the current working directory using the *here::here()* functionality. These data sets will be tab delimited files with a name describing the data, and for reproducibility, the date they were generated and the version of KEGG when the API was accessed. In addition to these flat files, *get\_kegg* will also create a named list with the three relavent KEGG data sets. The names of this list will describe the the data set.

``` r
suppressMessages(library(diffEnrich))

## run get_kegg() using rat
kegg_rno <- get_kegg('rno')
#> These files already exist in your working directory. New files will not be generated.
#> Kegg Release: Release_90.0+_06-24_Jun_19
```

Here are the files:

    kegg_to_pathway2019-04-26Release_90.0+_04-26_Apr_19.txt
    ncbi_to_kegg2019-04-26Release_90.0+_04-26_Apr_19.txt
    pathway_to_species2019-04-26Release_90.0+_04-26_Apr_19.txt

**Note:** Because it is assumed that the user might want to use the data sets generated by *get\_kegg*, it is careful not to overwrite data sets with exact names. *get\_kegg* checks the path provided for data sets generated 'same-day/same-version', and if it finds even one of the three, it will not re-write any of the data sets. It will still however, let the user know it is not writing out new data sets and still generate the named list object. Users can of course generate 'same-day/same-version' data sets in different directories if they so choose.

``` r
## run get_kegg() using rat
kegg_rno <- get_kegg('rno')
#> These files already exist in your working directory. New files will not be generated.
#> Kegg Release: Release_90.0+_06-24_Jun_19
```

### Step 2: Perform individual enrichment analysis

In this step we will use the *pathEnrich* function to identify KEGG pathways that are enriched based on a list of genes we are interested in and based on a list of background genes. This function may not always use the complete list of genes provided by the user. Specifically, it will only use the genes from the list provided that are also in the most current species list pulled from the KEGG REST API using *get\_kegg*, or from the older KEGG data loaded by the user from a previous *get\_kegg* call. The *pathEnrich* function should be run at least twice, once for the genes of interest and once for the background. Each *pathEnrich* call generates a dataframe summarizing the results of a traditional pathway enrichment analysis in which a Fisher's Exact test is used to identify which KEGG pathways are enriched by the user's list of interesting genes with repect to background enrichment.

``` r
# run pathEnrich using kegg_rno
## Genes of interest
sig_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$sigGenes)
## Background
bkg_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$background)
knitr::kable(head(sig_pe),
             caption = "Table 1. Head of sig_pe dataframe generated using pathEnrich") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), full_width = T)
#> Warning in kableExtra::kable_styling(., bootstrap_options = c("striped", :
#> Please specify format in kable. kableExtra can customize either HTML or
#> LaTeX outputs. See https://haozhu233.github.io/kableExtra/ for details.
```

|     | V1            | V2                                                       |  KEGG\_cnt|  KEGG\_in\_list|  numTested|  numSig|  expected|  enrich\_p|        fdr|
|-----|:--------------|:---------------------------------------------------------|----------:|---------------:|----------:|-------:|---------:|----------:|----------:|
| 172 | path:rno04530 | Tight junction - Rattus norvegicus (rat)                 |        170|              19|       8834|     293|  5.638442|  0.0000025|  0.0008089|
| 295 | path:rno05210 | Colorectal cancer - Rattus norvegicus (rat)              |         88|              12|       8834|     293|  2.918723|  0.0000277|  0.0045087|
| 142 | path:rno04144 | Endocytosis - Rattus norvegicus (rat)                    |        275|              22|       8834|     293|  9.121010|  0.0000739|  0.0067965|
| 313 | path:rno05231 | Choline metabolism in cancer - Rattus norvegicus (rat)   |         99|              12|       8834|     293|  3.283564|  0.0000892|  0.0067965|
| 298 | path:rno05213 | Endometrial cancer - Rattus norvegicus (rat)             |         58|               9|       8834|     293|  1.923704|  0.0001042|  0.0067965|
| 202 | path:rno04722 | Neurotrophin signaling pathway - Rattus norvegicus (rat) |        125|              13|       8834|     293|  4.145913|  0.0002152|  0.0116927|

*pathEnrich* generates a dataframe with 9 columns described below.
