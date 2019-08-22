#' plotFoldEnrichment
#' @description This function uses the results generated using \code{\link{diffEnrich}}
#' to generate a bar plot describing the fold enrichment of a set of given KEGG
#' pathways stratified by their enrichment in list 1 or list 2. Users can plot
#' all pathways based on the adjusted p-value threshold used in \code{\link{diffEnrich}}
#' and the top N pathways sorted by the adjusted p-value threshold used in \code{\link{diffEnrich}}.
#' \code{\link{plotFoldEnrich}} returns a ggplot2 object so users can add additional
#' customizations.
#' @param de_res Dataframe. Generated using \code{\link{diffEnrich}}
#' @param pval Numeric. Threshold for filtering pathways based on adjusted pvalue in de_res
#' @param N Numeric. Number of top pathways to plot after filtering based on pval
#'
#' @return
#'
#' @import dplyr
#'         ggplot2
#' @importFrom reshape2 melt
#' @export
#'
#' @examples
#' \dontrun{
#' plot <- plotFoldEnrichment(de_res = diffEnrich, pval = 0.05, N = 5)
#' }
plotFoldEnrichment <- function(de_res, pval, N){
  library(dplyr)
  library(ggplot2)
  ## Check arguments
  if(missing(de_res)){stop("Argument missing: de_res")}
  if(missing(pval)){stop("Argument missing: pval - please provide a threshold")}
  if(missing(N)){stop("Argument missing: N - if you'd like to plot top pathways, please provide a threshold and make sure N > 0")}
  if(N < 1){stop("Number of top genes (N) must be > 0")}

  ###########################################################
  # Prepare and reshape data for plotting using ggplot
  ###########################################################

  ## Strip extra columns from de_res and filter based on pval. Then sort by pval.
  df <- de_res %>%
    dplyr::select(KEGG_PATHWAY_ID, KEGG_PATHWAY_description,
           fold_enrichment_list1, fold_enrichment_list2,
           enrich_p_list1, enrich_p_list2,
           odd_ratio, diff_enrich_adjusted) %>%
    dplyr::mutate(KEGG_PATHWAY_description = sapply(strsplit(KEGG_PATHWAY_description, split = " - "), function(x) x[1])) %>%
    dplyr::arrange(diff_enrich_adjusted) %>%
    dplyr::filter(diff_enrich_adjusted < pval) %>%
    dplyr::slice(1:N)

  ## Melt data set
  df.melt <-reshape2::melt(df, id.vars = c('KEGG_PATHWAY_ID', 'KEGG_PATHWAY_description'))

  ## Clean up melted data frame
  df.ss <- df.melt %>%
    dplyr::filter(variable %in% c("fold_enrichment_list1", "fold_enrichment_list2",
                         "enrich_p_list1", "enrich_p_list2",
                         "diff_enrich_adjusted"))

  ## get vector of pvals
  pvals <- dplyr::subset(df.ss, variable %in% c("enrich_p_list1", "enrich_p_list2"))

  ## Generate data set to be used for plotting
  bardat <- dplyr::subset(df.ss, variable %in% c("fold_enrichment_list1", "fold_enrichment_list2")) %>%
    dplyr::mutate(alpha = log10(pvals$value),
           pvals = pvals$value) %>%
    dplyr::arrange(pvals)

  ###########################################################
  # Generate plot
  ###########################################################
  g <- ggplot(bardat, aes(x=reorder(KEGG_PATHWAY_description, -pvals), y=value)) +
    geom_bar(stat="identity", aes(col=variable, group=variable, fill=pvals), position="dodge") +
    ylim(0, max(d$value) + 0.6) + xlab("") +
    coord_flip() +
    scale_fill_brewer(palette = "Set1",
                      name="",
                      breaks=c("fold_enrichment_list1", "fold_enrichment_list2"),
                      labels=c("Fold Enrichment in \nlist 1\n", "Fold enrichment in \nlist 2\n")) +
    scale_fill_continuous(trans = 'log10') +
    geom_text(data=subset(df.ss, variable %in% c("diff_enrich_adjusted")),
              aes(x = KEGG_PATHWAY_description, y = (max(bardat$value) + 0.3), label = round(value, 4))) +
    labs(alpha = "List specific p-value")

  ld <- layer_data(g)
  ld <- ld[, c("xmin", "xmax", "ymin", "ymax")]


  # Match back to original data
  matches <- match(ld$ymax, bardat$value)

  # Supplement with original data
  ld$pvals <- log10((bardat$pvals[matches]))
  ld$descr <- bardat$KEGG_PATHWAY_description[matches]
  ld$vars <- bardat$variable[matches]

  ggplot(mapping = aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) +
    geom_rect(data = ld[ld$vars == "fold_enrichment_list1", ], aes(fill = pvals)) +
    scale_fill_gradient(low = "red", high = "transparent",
                        limits = c(min(ld$pvals), 0),
                        name = "P-values List 1") +
    new_scale_fill() +
    geom_rect(data = ld[ld$vars == "fold_enrichment_list2", ], aes(fill = pvals)) +
    scale_fill_gradient(low =  "blue", high = "transparent",
                        limits = c(min(ld$pvals), 0),
                        name = "P-values List 2") +
    scale_x_continuous(breaks = seq_along(unique(ld$descr)),
                       labels = unique(ld$descr)) +
    coord_flip()
  return(p)
}
