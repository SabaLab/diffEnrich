#' plotFoldEnrichment
#' @description This function uses the results generated using \code{\link{diffEnrich}}
#' to generate a bar plot describing the fold enrichment of a set of given KEGG
#' pathways stratified by their enrichment in list 1 or list 2. Users can plot
#' all pathways based on the adjusted p-value threshold used in \code{\link{diffEnrich}}
#' or the top N pathways sorted by the adjusted p-value threshold used in \code{\link{diffEnrich}}.
#' \code{\link{plotFoldEnrich}} returns a ggplot2 object so users can add additional
#' customizations.
#' @param de_res
#' @param pval
#' @param N
#'
#' @return
#' @export
#'
#' @examples
plotFoldEnrichment <- function(de_res, pval, N){

}
