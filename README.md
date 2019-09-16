
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Build
status](https://ci.appveyor.com/api/projects/status/xwu8nket2u1pd5ij?svg=true)](https://ci.appveyor.com/project/hsmith9002/diffenrich)

[![Build
Status](https://travis-ci.com/SabaLab/diffEnrich.svg?token=M2jELEzTYYqmxZMY6hpb&branch=master)](https://travis-ci.com/SabaLab/diffEnrich)

# diffEnrich

## Introduction

The goal of diffEnrich is to compare functional enrichment between two
experimentally-derived groups of genes or proteins. Given a list of gene
symbols, *diffEnrich* will perform differential enrichment analysis
using the Kyoto Encyclopedia of Genes and Genomes (KEGG) REST API. This
package provides a number of functions that are intended to be used in a
pipeline (See Figure 1). Briefly, the user provides a KEGG formatted
species id for either human, mouse or rat, and the package will download
and clean species specific ENTREZ gene IDs and map them to their
respective KEGG pathways by accessing KEGG’s REST API. KEGG’s API is
used to guarantee the most up-to-date pathway data from KEGG. Next, the
user will identify significantly enriched pathways from two different
gene sets, and finally, the user will identify pathways that are
differentially enriched between the two gene sets. In addition to the
analysis pipeline, this package also provides a plotting function.

**Note on figure legends:** To view figure legends, hover mouse over
image.

**The KEGG REST API**

KEGG is a database resource for understanding high-level functions of a
biological system, such as a cell, an organism and an ecosystem, from
genomic and molecular-level information
[REF](https://www.kegg.jp/kegg/kegg1a.html). KEGG is an integrated
database resource consisting of eighteen databases that are clustered
into 4 main categories: 1) systems information (e.g. hierarchies and
maps), 2) genomic information (e.g. genes and proteins), 3) chemical
information (e.g. biochemical reactions), and 4) health information
(e.g. human disease and drugs)
[REF](https://www.kegg.jp/kegg/kegg1a.html).

In 2012 KEGG released its first application programming interface (API),
and has been adding features and functionality ever since. There are
benefits to using an API. First, API’s like KEGG’s allow users to
perform customized analyses with the most up-to-date versions of the
data contained in the database. In addition, accessing the KEGG API is
very easy using statistical programming tools like R or Python and
integrating data pulls into user’s code makes the program reproducible.
To further enforce reproducibilty *diffEnrich* adds a date and KEGG
release tag to all data files it generates from accessing the API. For
update histories and release notes for the KEGG REST API please go
[here](https://www.kegg.jp/kegg/rest/).

<img src="man/figures/README-unnamed-chunk-1-1.png" title="Figure 1. diffEnrich Analysis pipeline. Functions within the diffEnrich package are represented by blue rectangles. The data that must be provided by the user is represented by the pruple ovals. Data objects generated by a function in diffEnrich are representaed by red ovals. The external call of the get_kegg function to the KEGG REST API is represented in yellow." alt="Figure 1. diffEnrich Analysis pipeline. Functions within the diffEnrich package are represented by blue rectangles. The data that must be provided by the user is represented by the pruple ovals. Data objects generated by a function in diffEnrich are representaed by red ovals. The external call of the get_kegg function to the KEGG REST API is represented in yellow." width="100%" />

**Motivating experimental design for differential enrichment**

A recent
[study](https://onlinelibrary.wiley.com/doi/full/10.1111/acer.13766)
explored the hepatic mechanism for removal of toxic lipid aldehydes via
conjugation with glutathione (Cheng et al.,
[2001](https://www.ncbi.nlm.nih.gov/pubmed/11488593?dopt=Abstract);
Gallagher et al.,
[2007](https://www.ncbi.nlm.nih.gov/pubmed/17553661?dopt=Abstract)) and
the primary enzyme that catalyzes this conjugation, glutathione
S‐transferase A4‐4 (GSTA4). Specifically, the researchers examine the
role of the GSTA4 gene on protein carbonylation and the progression of
liver injury in a model consisting of long‐term (116 days) chronic
ethanol (EtOH) consumption followed by a single EtOH binge.

Functional enrichment of carbonylated proteins for KEGG pathways was
tested using a 1‐sided Fisher’s exact test in each experimental group (2
genotypes × 3 treatment conditions = 6 experimental groups).
Differential enrichment between experimental groups was examined using a
2‐sided Fisher’s exact test. For KEGG pathway enrichment, proteins were
mapped to pathways using their UniProt ID, and databases were downloaded
from the KEGG API.

Note: This example uses proteins as the feature of interest, however
*diffEnrich* currently only supports genes as the feature of interest.

Differential enrichment analysis of carbonylated proteins indicated that
compared to chow‐fed animals, the most overrepresented group of proteins
that was significantly adducted after long‐term EtOH exposure was
ribosomal proteins.

## Installation

You can install the released version of diffEnrich from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("diffEnrich") 
```

## Example

### Step 1: Collect and clean pathways from KEGG API

First we will use the *get\_kegg* function to access the KEGG REST API
and download the data sets required to perform our downstream analysis.
This function takes two arguments. The first, ‘species’ is required.
Currently, *diffEnrich* supports three species, and the argument is a
character string using the KEGG code
[REF](https://www.pnas.org/content/suppl/2008/09/11/0806162105.DCSupplemental/ST1_PDF.pdf):
Homo sapiens (human), use ‘hsa’; Mus musculus (mouse), use ‘mmu’, and
Rattus norvegicus (rat), use ‘rno’. The second, ‘path’ is also passed as
a character string, and is the path of the directory in which the user
would like to write the data sets downloaded from the KEGG REST API. If
the user does not provide a path, the data sets will be automatically
written to the current working directory using the *here::here()*
functionality. These data sets will be tab delimited files with a name
describing the data, and for reproducibility, the date they were
generated and the version of KEGG when the API was accessed. In addition
to these flat files, *get\_kegg* will also create a named list with the
three relevant KEGG data sets. The names of this list will describe the
data set. For a detailed description of list elements use *?get\_kegg*.

``` r
## run get_kegg() using rat
kegg_rno <- get_kegg('rno')
#> These files already exist in your working directory. New files will not be generated.
#> Kegg Release: Release_91.0+_09-16_Sep_19
```

Here are examples of the output files:

    kegg_to_pathway2019-04-26Release_90.0+_04-26_Apr_19.txt
    ncbi_to_kegg2019-04-26Release_90.0+_04-26_Apr_19.txt
    pathway_to_species2019-04-26Release_90.0+_04-26_Apr_19.txt

**Note:** Because it is assumed that the user might want to use the data
sets generated by *get\_kegg*, it is careful not to overwrite data sets
with exact names. *get\_kegg* checks the path provided for data sets
generated ‘same-day/same-version’, and if it finds even one of the
three, it will not re-write any of the data sets. It will still however,
let the user know it is not writing out new data sets and still generate
the named list object. Users can generate ‘same-day/same-version’ data
sets in different directories if they so choose.

``` r
## run get_kegg() using rat
kegg_rno <- get_kegg('rno')
#> These files already exist in your working directory. New files will not be generated.
#> Kegg Release: Release_91.0+_09-16_Sep_19
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<caption>

Table 1. Description of data sets generated from accessing KEGG REST API

</caption>

<thead>

<tr>

<th style="text-align:left;">

get\_kegg.list.object

</th>

<th style="text-align:left;">

Object.description

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

ncbi\_to\_kegg

</td>

<td style="text-align:left;">

ncbi gene ID \<– mapped to –\> KEGG gene ID

</td>

</tr>

<tr>

<td style="text-align:left;">

kegg\_to\_pathway

</td>

<td style="text-align:left;">

KEGG gene ID \<– mapped to –\> KEGG pathway ID

</td>

</tr>

<tr>

<td style="text-align:left;">

pathway\_to\_species

</td>

<td style="text-align:left;">

KEGG pathway ID \<– mapped to –\> KEGG pathway species description

</td>

</tr>

</tbody>

</table>

### Step 2: Perform enrichment analysis of individual gene sets

In this step we will use the *pathEnrich* function to identify KEGG
pathways that are enriched (i.e. over-represented) based on a gene list
of interest. User gene lists must also be character vectors and be
formatted as ENTREZ gene IDs. The *clusterProfiler* package offers a
nice function (*bitr*) that maps gene symbols and Ensembl IDs to ENTREZ
gene IDs, and an example can be seen in their
[vignette](https://yulab-smu.github.io/clusterProfiler-book/chapter5.html#supported-organisms).

``` r
## View sample gene lists from package data
head(geneLists$list1)
#> [1] "361692"    "293654"    "293655"    "500974"    "100361529" "171434"
head(geneLists$list2)
#> [1] "315547" "315548" "315549" "315550" "50938"  "58856"
```

This function may not always use the complete list of genes provided by
the user. Specifically, it will only use the genes from the list
provided that are also in the most current species list pulled from the
KEGG REST API using *get\_kegg*, or from the older KEGG data loaded by
the user from a previous *get\_kegg* call. The *pathEnrich* function
should be run at least twice, once for the genes of interest in list 1
and once for the genes of interest in list2. Each *pathEnrich* call
generates a data frame summarizing the results of an enrichment analysis
in which a Fisher’s Exact test is used to identify which KEGG pathways
are enriched within the user’s list of interesting genes compared to all
genes annotated to a KEGG pathway. P-values from the Fisher’s Exact test
are adjusted for multiple comparisons by controlling the False Discovery
Rate (FDR) at 0.05.

``` r
# run pathEnrich using kegg_rno
## List 1
list1_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$list1)
## list2
list2_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$list2) 
```

<table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">

<caption>

Table 2. First 6 rows of list1\_pe data frame generated using pathEnrich

</caption>

<thead>

<tr>

<th style="text-align:left;">

KEGG\_PATHWAY\_ID

</th>

<th style="text-align:left;">

KEGG\_PATHWAY\_description

</th>

<th style="text-align:right;">

KEGG\_PATHWAY\_cnt

</th>

<th style="text-align:right;">

KEGG\_PATHWAY\_in\_list

</th>

<th style="text-align:right;">

KEGG\_DATABASE\_cnt

</th>

<th style="text-align:right;">

KEG\_DATABASE\_in\_list

</th>

<th style="text-align:right;">

expected

</th>

<th style="text-align:right;">

enrich\_p

</th>

<th style="text-align:right;">

fdr

</th>

<th style="text-align:right;">

fold\_enrichment

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

rno04530

</td>

<td style="text-align:left;">

Tight junction - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

170

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

5.662827

</td>

<td style="text-align:right;">

0.0000035

</td>

<td style="text-align:right;">

0.0008093

</td>

<td style="text-align:right;">

3.355214

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05135

</td>

<td style="text-align:left;">

Yersinia infection - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

128

</td>

<td style="text-align:right;">

16

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

4.263776

</td>

<td style="text-align:right;">

0.0000049

</td>

<td style="text-align:right;">

0.0008093

</td>

<td style="text-align:right;">

3.752542

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05210

</td>

<td style="text-align:left;">

Colorectal cancer - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

88

</td>

<td style="text-align:right;">

12

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

2.931346

</td>

<td style="text-align:right;">

0.0000318

</td>

<td style="text-align:right;">

0.0034870

</td>

<td style="text-align:right;">

4.093683

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05231

</td>

<td style="text-align:left;">

Choline metabolism in cancer - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

99

</td>

<td style="text-align:right;">

12

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

3.297764

</td>

<td style="text-align:right;">

0.0001032

</td>

<td style="text-align:right;">

0.0067154

</td>

<td style="text-align:right;">

3.638829

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05213

</td>

<td style="text-align:left;">

Endometrial cancer - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

58

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

1.932023

</td>

<td style="text-align:right;">

0.0001132

</td>

<td style="text-align:right;">

0.0067154

</td>

<td style="text-align:right;">

4.658328

</td>

</tr>

<tr>

<td style="text-align:left;">

rno04144

</td>

<td style="text-align:left;">

Endocytosis - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

275

</td>

<td style="text-align:right;">

22

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

9.160456

</td>

<td style="text-align:right;">

0.0001225

</td>

<td style="text-align:right;">

0.0067154

</td>

<td style="text-align:right;">

2.401627

</td>

</tr>

</tbody>

</table>

*pathEnrich* generates a data frame with 9 columns described below.
Details also provided in *pathEnrich* documentation. Use *?pathEnrich*.

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">

<caption>

Table 3. Description of columns is dataframe generated by pathEnrich

</caption>

<thead>

<tr>

<th style="text-align:left;">

Column Names

</th>

<th style="text-align:left;">

Column Description

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_ID

</td>

<td style="text-align:left;">

KEGG Pathway Identifier

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_description

</td>

<td style="text-align:left;">

Description of KEGG Pathway (provided by KEGG)

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_cnt

</td>

<td style="text-align:left;">

Number of Genes in KEGG Pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_in\_list

</td>

<td style="text-align:left;">

Number of Genes from gene list in KEGG Pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_DATABASE\_cnt

</td>

<td style="text-align:left;">

Number of Genes in KEGG Database

</td>

</tr>

<tr>

<td style="text-align:left;">

KEG\_DATABASE\_in\_list

</td>

<td style="text-align:left;">

Number of Genes from gene list in KEGG Database

</td>

</tr>

<tr>

<td style="text-align:left;">

expected

</td>

<td style="text-align:left;">

Expected number of genes from list to be in KEGG pathway by chance

</td>

</tr>

<tr>

<td style="text-align:left;">

enrich\_p

</td>

<td style="text-align:left;">

P-value for enrichment within the KEGG pathway for list genes

</td>

</tr>

<tr>

<td style="text-align:left;">

fdr

</td>

<td style="text-align:left;">

False Discovery Rate (Benjamini and Hochberg) to account for multiple
testing across KEGG pathways

</td>

</tr>

<tr>

<td style="text-align:left;">

fold\_enrichment

</td>

<td style="text-align:left;">

Ratio of number of genes observed from the gene list annotated to the
KEGG pathway to the number of genes expected from the gene list
annotated to the KEGG pathway if there was no enrichment
(i.e. KEGG\_PATHWAY\_in\_list/expected)

</td>

</tr>

</tbody>

</table>

### Step 3: Identify differentially enriched KEGG pathways

The *diffEnrich* function will merge two results from the *pathEnrich*
calls generated above. Specifically, the data frame ‘list1\_pe’ and the
data frame ‘list2\_pe’ will be merged by the following columns:
“KEGG\_PATHWAY\_ID”, “KEGG\_PATHWAY\_description”,
“KEGG\_PATHWAY\_cnt”, “KEGG\_DATABASE\_cnt”. This merged data set
will then be used to perform differential enrichment using the same
method and p-value calculation as described above. Users do have the
option of choosing a method for multiple testing adjustment. Users can
choose from those supported by *stats::p.adjust* for multiple correction
options, and the default is the False Discovery Rate (Benjamini and
Hochberg, [1995](http://www.jstor.org/stable/2346101)).

``` r
## Perform differential enrichment
diff_enrich <- diffEnrich(list1_pe = list1_pe, list2_pe = list2_pe, method = 'none') 
```

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">

<caption>

Table 4.First 6 rows from data frame generated by diffEnrich

</caption>

<thead>

<tr>

<th style="text-align:left;">

KEGG\_PATHWAY\_ID

</th>

<th style="text-align:left;">

KEGG\_PATHWAY\_description

</th>

<th style="text-align:right;">

KEGG\_PATHWAY\_cnt

</th>

<th style="text-align:right;">

KEGG\_DATABASE\_cnt

</th>

<th style="text-align:right;">

KEGG\_PATHWAY\_in\_list1

</th>

<th style="text-align:right;">

KEGG\_DATABASE\_in\_list1

</th>

<th style="text-align:right;">

expected\_list1

</th>

<th style="text-align:right;">

enrich\_p\_list1

</th>

<th style="text-align:right;">

fdr\_list1

</th>

<th style="text-align:right;">

fold\_enrichment\_list1

</th>

<th style="text-align:right;">

KEGG\_PATHWAY\_in\_list2

</th>

<th style="text-align:right;">

KEGG\_DATABASE\_in\_list2

</th>

<th style="text-align:right;">

expected\_list2

</th>

<th style="text-align:right;">

enrich\_p\_list2

</th>

<th style="text-align:right;">

fdr\_list2

</th>

<th style="text-align:right;">

fold\_enrichment\_list2

</th>

<th style="text-align:right;">

odd\_ratio

</th>

<th style="text-align:right;">

diff\_enrich\_p

</th>

<th style="text-align:right;">

diff\_enrich\_adjusted

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

rno04530

</td>

<td style="text-align:left;">

Tight junction - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

170

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

19

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

5.662827

</td>

<td style="text-align:right;">

0.0000035

</td>

<td style="text-align:right;">

0.0008093

</td>

<td style="text-align:right;">

3.355214

</td>

<td style="text-align:right;">

131

</td>

<td style="text-align:right;">

5308

</td>

<td style="text-align:right;">

101.89250

</td>

<td style="text-align:right;">

0.0000015

</td>

<td style="text-align:right;">

0.0000056

</td>

<td style="text-align:right;">

1.285669

</td>

<td style="text-align:right;">

0.3676651

</td>

<td style="text-align:right;">

0.0002936

</td>

<td style="text-align:right;">

0.0002936

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05135

</td>

<td style="text-align:left;">

Yersinia infection - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

128

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

16

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

4.263776

</td>

<td style="text-align:right;">

0.0000049

</td>

<td style="text-align:right;">

0.0008093

</td>

<td style="text-align:right;">

3.752542

</td>

<td style="text-align:right;">

105

</td>

<td style="text-align:right;">

5308

</td>

<td style="text-align:right;">

76.71906

</td>

<td style="text-align:right;">

0.0000001

</td>

<td style="text-align:right;">

0.0000003

</td>

<td style="text-align:right;">

1.368630

</td>

<td style="text-align:right;">

0.3520039

</td>

<td style="text-align:right;">

0.0005435

</td>

<td style="text-align:right;">

0.0005435

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05210

</td>

<td style="text-align:left;">

Colorectal cancer - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

88

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

12

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

2.931346

</td>

<td style="text-align:right;">

0.0000318

</td>

<td style="text-align:right;">

0.0034870

</td>

<td style="text-align:right;">

4.093683

</td>

<td style="text-align:right;">

81

</td>

<td style="text-align:right;">

5308

</td>

<td style="text-align:right;">

52.74435

</td>

<td style="text-align:right;">

0.0000000

</td>

<td style="text-align:right;">

0.0000000

</td>

<td style="text-align:right;">

1.535709

</td>

<td style="text-align:right;">

0.3655602

</td>

<td style="text-align:right;">

0.0032572

</td>

<td style="text-align:right;">

0.0032572

</td>

</tr>

<tr>

<td style="text-align:left;">

rno05213

</td>

<td style="text-align:left;">

Endometrial cancer - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

58

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

1.932023

</td>

<td style="text-align:right;">

0.0001132

</td>

<td style="text-align:right;">

0.0067154

</td>

<td style="text-align:right;">

4.658328

</td>

<td style="text-align:right;">

55

</td>

<td style="text-align:right;">

5308

</td>

<td style="text-align:right;">

34.76332

</td>

<td style="text-align:right;">

0.0000000

</td>

<td style="text-align:right;">

0.0000000

</td>

<td style="text-align:right;">

1.582127

</td>

<td style="text-align:right;">

0.3328275

</td>

<td style="text-align:right;">

0.0058775

</td>

<td style="text-align:right;">

0.0058775

</td>

</tr>

<tr>

<td style="text-align:left;">

rno04660

</td>

<td style="text-align:left;">

T cell receptor signaling pathway - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

106

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

11

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

3.530940

</td>

<td style="text-align:right;">

0.0007743

</td>

<td style="text-align:right;">

0.0193977

</td>

<td style="text-align:right;">

3.115318

</td>

<td style="text-align:right;">

79

</td>

<td style="text-align:right;">

5308

</td>

<td style="text-align:right;">

63.53297

</td>

<td style="text-align:right;">

0.0011075

</td>

<td style="text-align:right;">

0.0022631

</td>

<td style="text-align:right;">

1.243449

</td>

<td style="text-align:right;">

0.3901694

</td>

<td style="text-align:right;">

0.0072048

</td>

<td style="text-align:right;">

0.0072048

</td>

</tr>

<tr>

<td style="text-align:left;">

rno04657

</td>

<td style="text-align:left;">

IL-17 signaling pathway - Rattus norvegicus (rat)

</td>

<td style="text-align:right;">

95

</td>

<td style="text-align:right;">

8856

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

295

</td>

<td style="text-align:right;">

3.164521

</td>

<td style="text-align:right;">

0.0042709

</td>

<td style="text-align:right;">

0.0520419

</td>

<td style="text-align:right;">

2.844032

</td>

<td style="text-align:right;">

59

</td>

<td style="text-align:right;">

5308

</td>

<td style="text-align:right;">

56.93993

</td>

<td style="text-align:right;">

0.3737223

</td>

<td style="text-align:right;">

0.4605042

</td>

<td style="text-align:right;">

1.036180

</td>

<td style="text-align:right;">

0.3572935

</td>

<td style="text-align:right;">

0.0087538

</td>

<td style="text-align:right;">

0.0087538

</td>

</tr>

</tbody>

</table>

<table class="table table-striped table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">

<caption>

Table 5. Description of columns is dataframe generated by diffEnrich

</caption>

<thead>

<tr>

<th style="text-align:left;">

Column Names

</th>

<th style="text-align:left;">

Column Description

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_ID

</td>

<td style="text-align:left;">

KEGG Pathway Identifier

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_description

</td>

<td style="text-align:left;">

Description of KEGG Pathway (provided by KEGG)

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_cnt

</td>

<td style="text-align:left;">

Number of Genes in KEGG Pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_DATABASE\_cnt

</td>

<td style="text-align:left;">

Number of Genes in KEGG Database

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_in\_list1

</td>

<td style="text-align:left;">

Number of Genes from gene list 1 in KEGG Pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_DATABASE\_in\_list1

</td>

<td style="text-align:left;">

Number of Genes from gene list 1 in KEGG Database

</td>

</tr>

<tr>

<td style="text-align:left;">

expected\_list1

</td>

<td style="text-align:left;">

Expected number of genes from list 1 to be in KEGG pathway by chance

</td>

</tr>

<tr>

<td style="text-align:left;">

enrich\_p\_list1

</td>

<td style="text-align:left;">

P-value for enrichment of list 1 genes related to KEGG pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

fdr\_list1

</td>

<td style="text-align:left;">

False Discovery Rate (Benjamini and Hochberg) of enrich\_p\_list1 to
account for multiple testing across KEGG pathways

</td>

</tr>

<tr>

<td style="text-align:left;">

fold\_enrichment\_list1

</td>

<td style="text-align:left;">

Ratio of number of genes observed from the gene list 1 annotated to the
KEGG pathway to the number of genes expected from the gene list 1
annotated to the KEGG pathway if there was no enrichment
(i.e. KEGG\_PATHWAY\_in\_list1/expected\_list1)

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_PATHWAY\_in\_list2

</td>

<td style="text-align:left;">

Number of Genes from gene list 2 in KEGG Pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

KEGG\_DATABASE\_in\_list2

</td>

<td style="text-align:left;">

Number of Genes from gene list 2 in KEGG Database

</td>

</tr>

<tr>

<td style="text-align:left;">

expected\_list2

</td>

<td style="text-align:left;">

Expected number of genes from list 2 to be in KEGG pathway by chance

</td>

</tr>

<tr>

<td style="text-align:left;">

enrich\_p\_list2

</td>

<td style="text-align:left;">

P-value for enrichment of list 2 genes related to KEGG pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

fdr\_list2

</td>

<td style="text-align:left;">

False Discovery Rate (Benjamini and Hochberg) of enrich\_p\_list2 to
account for multiple testing across KEGG pathways

</td>

</tr>

<tr>

<td style="text-align:left;">

fold\_enrichment\_list2

</td>

<td style="text-align:left;">

Ratio of number of genes observed from the gene list 2 annotated to the
KEGG pathway to the number of genes expected from the gene list 2
annotated to the KEGG pathway if there was no enrichment
(i.e. KEGG\_PATHWAY\_in\_list2/expected\_list2)

</td>

</tr>

<tr>

<td style="text-align:left;">

odd\_ratio

</td>

<td style="text-align:left;">

Odds of a gene from list 2 being from this KEGG pathway / Odds of a gene
from list 1 being from this KEGG pathway

</td>

</tr>

<tr>

<td style="text-align:left;">

diff\_enrich\_p

</td>

<td style="text-align:left;">

P-value for differential enrichment of this KEGG pathway between list 1
and list 2

</td>

</tr>

<tr>

<td style="text-align:left;">

diff\_enrich\_adjusted

</td>

<td style="text-align:left;">

Multiple testing adjustment of diff\_enrich\_p (default = False
Discovery Rate (Benjamini and Hochberg))

</td>

</tr>

</tbody>

</table>

The result of the *diffEnrich* call is a data frame with the estimated
odds ratio generated by the Fisher’s Exact test and the associated
p-value.

### Step 4: Plot fold enrichment

*plotFoldEnrichment* generates a grouped bar plot using ggplot2 and the
*ggnewscale* package. There are 3 arguments: 1) *de\_res* is the
dataframe generated from the *diffEnrich* function, 2) *pval* is the
threshold for the adjusted p-value associated with differential
enrichment that will filter which KEGG pathways to plot, and 3) after
filtering based on *pval* *N* tells the function how many pathways to
plot. It is important to make a note that the significance of the fold
change is associated with the number of genes in the gene list. Notice
that in this example the pathways in gene list 2 have smaller fold
changes (shorter bars) than those in list 1, but that many of them are
more significant (darker blue). This is because there are more genes in
gene list 2 compared to gene list 1.

``` r
## Plot fold enrichment
plotFoldEnrichment(de_res = diff_enrich, pval = 0.05, N = 5)
```

<img src="man/figures/README-plotFoldEnrichment-1.png" title="Figure 2. Fold enrichment stratified by gene list. KEGG pathways are plotted on the y-axis and fold
enrichment is plotted on the x-axis. Each KEGG pathway has a bar depicting
its fold enrichment in list 1 (red) and its fold enrichment in list 2 (blue).
The transparency of the bars correspond to the unadjusted p-value for the
pathway's enrichment in the given list. The p-value presented as text to the
right of each pair of bars is the adjusted p-value (user defined: default is FDR) associated with the
differential enrichment of the pathway between the two lists, and the pathways
are ordered from top to bottom by this p-value (i.e. smallest p-value on top
of plot, and largest p-value on bottom of plot). The dotted line represents a fold enrichment of 1. Finally, the number of genes used
for analysis from each gene list (recall that this number may not be the same as the number of
genes in the user's original list) are reported below their respective p-values
in the legend." alt="Figure 2. Fold enrichment stratified by gene list. KEGG pathways are plotted on the y-axis and fold
enrichment is plotted on the x-axis. Each KEGG pathway has a bar depicting
its fold enrichment in list 1 (red) and its fold enrichment in list 2 (blue).
The transparency of the bars correspond to the unadjusted p-value for the
pathway's enrichment in the given list. The p-value presented as text to the
right of each pair of bars is the adjusted p-value (user defined: default is FDR) associated with the
differential enrichment of the pathway between the two lists, and the pathways
are ordered from top to bottom by this p-value (i.e. smallest p-value on top
of plot, and largest p-value on bottom of plot). The dotted line represents a fold enrichment of 1. Finally, the number of genes used
for analysis from each gene list (recall that this number may not be the same as the number of
genes in the user's original list) are reported below their respective p-values
in the legend." width="100%" />
