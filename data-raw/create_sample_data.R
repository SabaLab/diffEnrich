## This script reads in the the gene lists used in the examples and vignette.
## It then mapps these gene symbols to ENTREZ IDs per the requirements of
## the package, and saves them as data that loads with the package.

library(org.Rn.eg.db)
library(tibble)

## Read data
base <- here::here()
backgroundList <- utils::read.delim(file = paste0(base, "/../data/Gene_Lists/bkgrdGenes_forHarry", ".txt"),
                  header = FALSE,
                  sep = "\t",
                  stringsAsFactors = FALSE)$V1
sigGenesList <- utils::read.delim(file = paste0(base, "/../data/Gene_Lists/sigGenes_forHarry", ".txt"),
                                    header = FALSE,
                                    sep = "\t",
                                    stringsAsFactors = FALSE)$V1

## map symbols to ENTREZ IDs
backgroundENTZ <- mapIds(org.Rn.eg.db, backgroundList, 'ENTREZID', 'SYMBOL')
backgroundENTZ <- base::unname(backgroundENTZ)
sigGeneENTZ <- mapIds(org.Rn.eg.db, sigGenesList, 'ENTREZID', 'SYMBOL')
sigGeneENTZ <- base::unname(sigGeneENTZ)
geneLists <- list(background = backgroundENTZ,
                  sigGenes = sigGeneENTZ)

## save and compress
usethis::use_data(geneLists, compress = "xz")

## generate kegg data
kegg <- get_kegg('rat')

## save and compress
usethis::use_data(kegg, compress = "xz")
