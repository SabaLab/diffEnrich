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
#' @return data.frame. Dataframe generated from merging pathEnrich dataframes with the following added columns:
#'                     Estimate: Estimated odds ration calculated from Fisher's Exact test
#'                     P_value: Unadjusted p_value from Fisher's Exact test
#'
#' @export
#' @importFrom  stats fisher.test
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
    y <- stats::fisher.test(matrix(c(a,b,c,d), nrow = 2))
    est <- y$estimate
    pv <- y$p.value
    out.de <- data.frame(est, pv)
    return(out.de)
  }
  ## perform differential enrichment
  res <- cbind(ce, do.call('rbind', apply(ce[, c("KEGG_in_list_list2", "KEGG_in_list_list1", "numSig_list2", "numSig_list1")], 1,
               function(a){ de(a[1], a[2], a[3], a[4])})))
  res$adjusted_p <- stats::p.adjust(res$pv, method = method)
  ## update rownames
  rownames(res) <- res$KEGG_ID
  return(res)
}



#' .combineEnrich
#' @description This is a helper function for \code{diffEnrich}. This function takes the objects generated from \code{\link{pathEnrich}}.
#' If performing a dfferential enrichment analysis, the user will have 2 objects. There
#' will be one for the genes of interest and one for the background (see example for \code{\link{pathEnrich}}).
#' This function then merges the two dataframes using the following columns that should be present
#' in both objects (\code{by = c("V1", "V2", "KEGG_cnt", "numTested")}). This merged dataframe
#' will be used as the input for the differential enrichment function.
#'
#' @param list1_pe data.frame. Dataframe of enrichment results for genes of interest
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param  list2_pe data.frame. Dataframe of enrichment results for background genes
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
  combined_enrich <- merge(list1_pe, list2_pe, by = c("KEGG_ID", "KEGG_description", "KEGG_cnt", "numTested"))
  colnames(combined_enrich) <- gsub(".x", "_list1", colnames(combined_enrich), fixed = TRUE)
  colnames(combined_enrich) <- gsub(".y", "_list2", colnames(combined_enrich), fixed = TRUE)

  out <- combined_enrich
  return(out)
}
