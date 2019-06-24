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
#' @param range numeric vector. Vector containing the smallest and largest number of
#' significant groups for use in filtering pathways of interest (e.g. \code{c(0,6)}.
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
#' ## Generate individual enrichment results
#' sig_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$sigGenes)
#' bkg_pe <- pathEnrich(gk_obj = kegg, gene_list = geneLists$background)
#' ## Combine
#' combined_enrich <- combineEnrich(sig_pe, bkg_pe, threshold = 0.05, range = c(0, 6))
#'
combineEnrich <- function(sig_pe, bkg_pe, threshold = 0.05, range){
  ## argument check
  if(missing(sig_pe)){stop("Argument missing: sig_pe")}
  if(missing(bkg_pe)){stop("Argument missing: bkg_pe")}
  if(missing(threshold)){stop("Argument missing: threshold. Please provide an FDR cutoff for gene inclusion in summary table")}
  if(missing(range)){stop("Argument missing: range. Please provide a range of FDR cutoffs to filter of_interest pathways")}

  ## Merge results from first enrichment
  combined_enrich <- merge(sig_pe, bkg_pe, by = c("V1", "V2", "KEGG_cnt", "numTested"))
  colnames(combined_enrich) <- gsub(".x", "_sig", colnames(combined_enrich), fixed = TRUE)
  colnames(combined_enrich) <- gsub(".y", "_bkg", colnames(combined_enrich), fixed = TRUE)
  ## Define fdr threshold
  threshold <- threshold

  ## Get sum of significantly enriched genes based on fdr cutoff
  combined_enrich$num_groups_sig <- rowSums(combined_enrich[, grep("fdr", colnames(combined_enrich))] < threshold)

  ## Get group range of interest and subset data to only include pathways and fdr values
  of_interest <- combined_enrich[combined_enrich$num_groups_sig > range[1] & combined_enrich$num_groups_sig < range[2], ]
  groups <- c("sig", "bkg")
  of_interest_subset <- of_interest[, c("V1", "V2", paste("fdr", groups, sep = "_"))]

  ## Use logical to numeric to summarize sig_pattern
  combined_enrich$sig_pattern <- apply(combined_enrich[, grep("fdr", colnames(combined_enrich))], 1, function(a) paste(as.numeric(a<threshold), collapse = ""))
  sig_sum <- as.data.frame(table(rowSums(combined_enrich[, grep("enrich_p", colnames(combined_enrich))]<threshold)))

  ## Put out objects in list *THIS WILL NEED TO BE UPDATED*
  list.out <- list("combined_enrich" = combined_enrich,
                   "of_interest" = of_interest_subset,
                   "sig_sum" = sig_sum)
  return(list.out)
}
