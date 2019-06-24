#' combineEnrich
#' @description This function takes the objects generated from \code{\link{pathEnrich}}.
#' If performing a dfferential enrichment analysis, the user will have 2 objects. There
#' will be one for the genes of interest and one for the background (see example for \code{\link{pathEnrich}}).
#' This function then merges the two dataframes using the following columns that should be present
#' in both objects (\code{by = c("V1", "V2", "KEGG_cnt", "numTested")}). This merged dataframe
#' will be used as the input for the differential enrichment function. In addition to this
#' merged dataframe, this function will produce a table summarizing the number of significantly
#' enriched genes in each original object, based on a user defined fdr threshold.
#'
#' @param sig_pe data.frame. Dataframe of enrichment results for genes of interest
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param  bkg_pe data.frame. Dataframe of enrichment results for background genes
#' generated from \code{\link{pathEnrich}}. See example for \code{\link{pathEnrich}}.
#' @param threshold numeric. FDR cutoff for significant genes included in summary table.
#' (Default = 0.05).
#'
#' @return combined_enrich: An object of class data.frame that is the result of merging
#' \code{sig_pe} and \code{bkg_pe}, using the default joining implemented in the base
#' \code{\link{merge}} function.
#'         fdr_summary: An object of class data.frame that summarizes the number
#'         of significantly enriched genes from each original data set based on the
#'         fdr threshold value provided by the user.
#'
#' @export
#'
#' @examples
combineEnrich <- function(sig_pe, bkg_pe, threshold = 0.05){
  ## argument check
  if(missing(sig_pe)){stop("Argument missing: sig_pe")}
  if(missing(bkg_pe)){stop("Argument missing: bkg_pe")}
  if(missing(threshold)){stop("Argument missing: threshold. Please provide an FDR cutoff for gene inclusion in summary table")}

  ## Merge results from first enrichment
  combined_enrich <- merge(sig_pe, bkg_pe, by = c("V1", "V2", "KEGG_cnt", "numTested"))
  ## Define fdr threshold
  threshold <- threshold

  ## Get sum of significantly enriched genes based on fdr cutoff
  combined_enrich$num_groups_sig <- rowSums(combined_enrich[, grep("fdr", colnames(combined_enrich))] < threshold)

}
