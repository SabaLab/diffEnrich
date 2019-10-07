#' diffEnrich
#' @description This function takes the objects generated from \code{\link{pathEnrich}}.
#' If performing a dfferential enrichment analysis, the user will have 2 objects. There
#' will be one for the genes of interest and one for the background (see example for \code{\link{pathEnrich}}).
#' This function then uses a Fisher's Exact test to iddentify differentially enriched
#' pathways between the terms enriched in the gene-of-interest list and the pathways enriched
#' in the background. \code{diffEnrich} returns a dataframe containing differentially enriched
#' pathways with their associated estimated odds ratio, unadjusted p-value, and fdr adjusted
#' p-value.
#'
#' @param list1_pe data.frame. Dataframe of enrichment results for genes of interest
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param list2_pe data.frame. Dataframe of enrichment results for background genes
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param method character. Character string telling \code{diffEnrich} which method to
#' use for multiple testing correction. Available methods are thos provided by
#' \code{\link{p.adjust}}, and the default is "BH", or False Discovery Rate (FDR).
#'
#' @return res: An object of class data.frame that summarizes the results
#' of the differential enrichment and contains the following variables:
#'
#' \describe{
#'   \item{KEGG_PATHWAY_ID}{KEGG Pathway Identifier}
#'   \item{KEGG_PATHWAY_description}{Description of KEGG Pathway (provided by KEGG)}
#'   \item{KEGG_PATHWAY_cnt}{Number of Genes in KEGG Pathway}
#'   \item{KEGG_DATABASE_cnt}{Number of Genes in KEGG Database}
#'   \item{KEGG_PATHWAY_in_list1}{Number of Genes from gene list 1 in KEGG Pathway}
#'   \item{KEGG_DATABASE_in_list1}{Number of Genes from gene list 1 in KEGG Database}
#'   \item{expected_list1}{Expected number of genes from list 1 to be in KEGG pathway by chance (i.e., not enriched)}
#'   \item{enrich_p_list1}{P-value for enrichment of list 1 genes related to KEGG pathway}
#'   \item{p_adj_list1}{Multiple testing adjustment of enrich_p_list1 (default = False Discovery Rate (Benjamini and Hochberg))}
#'   \item{fold_enrichment_list1}{KEGG_PATHWAY_in_list1/expected_list1}
#'   \item{KEGG_PATHWAY_in_list2}{Number of Genes from gene list 2 in KEGG Pathway}
#'   \item{KEGG_DATABASE_in_list2}{Number of Genes from gene list 2 in KEGG Database}
#'   \item{expected_list2}{Expected number of genes from list 2 to be in KEGG pathway by chance (i.e., not enriched)}
#'   \item{enrich_p_list2}{P-value for enrichment of list 2 genes related to KEGG pathway}
#'   \item{p_adj_list2}{Multiple testing adjustment of enrich_p_list2 (default = False Discovery Rate (Benjamini and Hochberg))}
#'   \item{fold_enrichment_list2}{KEGG_PATHWAY_in_list2/expected_list2}
#'   \item{odd_ratio}{Odds of a gene from list 2 being from this KEGG pathway / Odds of a gene from list 1 being from this KEGG pathway}
#'   \item{diff_enrich_p}{P-value for differential enrichment of this KEGG pathway between list 1 and list 2}
#'   \item{diff_enrich_adjusted}{Multiple testing adjustment of diff_enrich_p (default = False Discovery Rate (Benjamini and Hochberg))}
#' }
#'
#' @export
#' @importFrom  stats fisher.test
#' @importFrom  rlang .data
#' @import dplyr
#'
#' @examples
#' ## Generate individual enrichment reults
#' list1_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$list1)
#' list2_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$list2)
#'
#' ## Perform differential enrichment
#' dif_enrich <- diffEnrich(list1_pe = list1_pe, list2_pe = list2_pe, method = 'none')
#'
diffEnrich <- function(list1_pe, list2_pe, method = 'BH'){
  ## Call .combineEnrich helper function
  ce <- .combineEnrich(list1_pe = list1_pe, list2_pe = list2_pe)

  ## Build diffEnrich Fisher's Exact function
  de <- function(a,b,c,d){
    y <- stats::fisher.test(matrix(c(a,b,c-a,d-b), nrow = 2))
    est <- y$estimate
    pv <- y$p.value
    out.de <- data.frame(est, pv)
    return(out.de)
  }
  ## perform differential enrichment
  res <- cbind(ce, do.call('rbind', apply(ce[, c("KEGG_PATHWAY_in_list2", "KEGG_PATHWAY_in_list1",
                                                 "KEGG_DATABASE_in_list2", "KEGG_DATABASE_in_list1")], 1,
               function(a){ de(a[1], a[2], a[3], a[4])})))
  res$adjusted_p <- stats::p.adjust(res$pv, method = method)
  colnames(res) <- c("KEGG_PATHWAY_ID", "KEGG_PATHWAY_description", "KEGG_PATHWAY_cnt", "KEGG_DATABASE_cnt",
                     "KEGG_PATHWAY_in_list1", "KEGG_DATABASE_in_list1", "expected_list1", "enrich_p_list1",
                     "p_adj_list1", "fold_enrichment_list1", "KEGG_PATHWAY_in_list2", "KEGG_DATABASE_in_list2", "expected_list2",
                     "enrich_p_list2", "p_adj_list2", "fold_enrichment_list2", "odd_ratio", "diff_enrich_p", "diff_enrich_adjusted")

  ## re-order table based on adjusted p-value
  # library(dplyr)
  res <- res %>%
    arrange(.data$diff_enrich_adjusted)

  ## update rownames
  rownames(res) <- res$KEGG_PATHWAY_ID
  return(res)
}



#' .combineEnrich
#' @description This is a helper function for \code{diffEnrich}. This function takes the objects generated from \code{\link{pathEnrich}}.
#' If performing a dfferential enrichment analysis, the user will have 2 objects. There
#' will be one for list1 and one for list2(see example for \code{\link{pathEnrich}}).
#' This function then merges the two data frames using the following columns that should be present
#' in both objects (\code{by = c("KEGG_PATHWAY_ID", "KEGG_PATHWAY_description", "KEGG_PATHWAY_cnt", "KEGG_DATABASE_cnt")}). This merged data frame
#' will be used as the input for the differential enrichment function.
#'
#' @param list1_pe data.frame. Data frame of enrichment results for list1
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param  list2_pe data.frame. Data frame of enrichment results for list2
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#'
#' @return combined_enrich: An object of class data.frame that is the result of merging
#' \code{list1_pe} and \code{list2_pe}, using the default joining implemented in the base
#' \code{\link{merge}} function.
#'
#'
.combineEnrich <- function(list1_pe, list2_pe){
  ## argument check
  if(missing(list1_pe)){stop("Argument missing: list1_pe")}
  if(missing(list2_pe)){stop("Argument missing: list2_pe")}

  ## Merge results from first enrichment
  combined_enrich <- merge(list1_pe$enrich_table, list2_pe$enrich_table, by = c("KEGG_PATHWAY_ID", "KEGG_PATHWAY_description", "KEGG_PATHWAY_cnt", "KEGG_DATABASE_cnt"))
  colnames(combined_enrich) <- gsub(".x", "_list1", colnames(combined_enrich), fixed = TRUE)
  colnames(combined_enrich) <- gsub(".y", "_list2", colnames(combined_enrich), fixed = TRUE)
  colnames(combined_enrich) <- c("KEGG_PATHWAY_ID", "KEGG_PATHWAY_description", "KEGG_PATHWAY_cnt", "KEGG_DATABASE_cnt",
                                 "KEGG_PATHWAY_in_list1", "KEGG_DATABASE_in_list1", "expected_list1", "enrich_p_list1",
                                 "p_adj_list1", "fold_enrichment_list1", "KEGG_PATHWAY_in_list2", "KEGG_DATABASE_in_list2", "expected_list2",
                                 "enrich_p_list2", "p_adj_list2", "fold_enrichment_list2")

  out <- combined_enrich
  return(out)
}
