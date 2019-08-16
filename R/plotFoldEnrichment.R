#' plotFoldEnrichment
#' @description This function uses the results generated using \code{\link{diffEnrich}}
#' to generate a bar plot describing the fold enrichment of a set of given KEGG
#' pathways stratified by their enrichment in list 1 or list 2. Users can plot
#' all pathways based on the adjusted p-value threshold used in \code{\link{diffEnrich}}
#' and the top N pathways sorted by the adjusted p-value threshold used in \code{\link{diffEnrich}}.
#' \code{\link{plotFoldEnrich}} returns a ggplot2 object so users can add additional
#' customizations.
#' @param de_res
#' @param pval
#' @param N
#'
#' @return
#'
#' @import dplyr
#' @export
#'
#' @examples
plotFoldEnrichment <- function(de_res, pval, N){
  ## Check arguments
  if(missing(de_res)){stop("Argument missing: de_res")}
  if(missing(pval)){stop("Argument missing: pval - please provide a threshold")}
  if(missing(N)){stop("Argument missing: N - if you'd like to plot top pathways, please provide a threshold and make sure N > 0")}
  if(N < 1){stop("Number of top genes (N) must be > 0")}

  ## Strip extra columns from de_res and filter based on pval. Then sort by pval.
  df <- de_res %>%
    select(KEGG_PATHWAY_ID, KEGG_PATHWAY_description,
           fold_enrichment_list1, fold_enrichment_list2,
           enrich_p_list1, enrich_p_list2,
           odd_ratio, diff_enrich_adjusted) %>%
    arrange(diff_enrich_adjusted) %>%
    filter(diff_enrich_adjusted < 0.05) %>%
    slice(1:N)

}
