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
#' @param sig_pe data.frame. Dataframe of enrichment results for genes of interest
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param  bkg_pe data.frame. Dataframe of enrichment results for background genes
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#'
#' @return data.frame. Dataframe with 5 columns.
#'                     KEGG_pathway ID: KEGG pathway ID
#'                     Description: KEGG pathway description
#'                     Estimate: Estimated odds ration calculated from Fisher's Exact test
#'                     P_value: Unadjusted p_value from Fisher's Exact test
#'                     FDR: FDR calculated using \code{p.adjust(x, method = "BH")}
#' @export
#'
#' @examples
diffEnrich <- function(sig_pe, bkg_pe){
  ## Call .combineEnrich helper function
  ce <- .combineEnrich(sig_pe = sig_pe, bkg_pe = bkg)

  ## Build diffEnrich Fisher's Exact function
  de <- function(x){
    y <- stats::fisher.test(matrix(c(a,b,c,d), nr = 2))
    est <- y$estimate
    pv <- y$p.value
    out.de <- data.frame(est, pv)
    return(out.de)
  }

}




































#' .combineEnrich
#' @description This is a helper function for \code{diffEnrich}. This function takes the objects generated from \code{\link{pathEnrich}}.
#' If performing a dfferential enrichment analysis, the user will have 2 objects. There
#' will be one for the genes of interest and one for the background (see example for \code{\link{pathEnrich}}).
#' This function then merges the two dataframes using the following columns that should be present
#' in both objects (\code{by = c("V1", "V2", "KEGG_cnt", "numTested")}). This merged dataframe
#' will be used as the input for the differential enrichment function.
#'
#' @param sig_pe data.frame. Dataframe of enrichment results for genes of interest
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param  bkg_pe data.frame. Dataframe of enrichment results for background genes
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#'
#' @return combined_enrich: An object of class data.frame that is the result of merging
#' \code{sig_pe} and \code{bkg_pe}, using the default joining implemented in the base
#' \code{\link{merge}} function.
#'
#'
.combineEnrich <- function(sig_pe, bkg_pe){
  ## argument check
  if(missing(sig_pe)){stop("Argument missing: sig_pe")}
  if(missing(bkg_pe)){stop("Argument missing: bkg_pe")}

  ## Merge results from first enrichment
  combined_enrich <- merge(sig_pe, bkg_pe, by = c("V1", "V2", "KEGG_cnt", "numTested"))
  colnames(combined_enrich) <- gsub(".x", "_sig", colnames(combined_enrich), fixed = TRUE)
  colnames(combined_enrich) <- gsub(".y", "_bkg", colnames(combined_enrich), fixed = TRUE)

  out <- combined_enrich
  return(out)
}
