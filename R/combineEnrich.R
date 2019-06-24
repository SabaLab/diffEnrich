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
#' @return
#' @export
#'
#' @examples
combineEnrich <- function(){

}
