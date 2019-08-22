#' plotFoldEnrichment
#' @description This function uses the results generated using \code{\link{diffEnrich}}
#' to generate a bar plot describing the fold enrichment of a set of given KEGG
#' pathways stratified by their enrichment in list 1 or list 2. Users can plot
#' all pathways based on the adjusted p-value threshold used in \code{\link{diffEnrich}}
#' and the top N pathways sorted by the adjusted p-value threshold used in \code{\link{diffEnrich}}.
#' \code{plotFoldEnrich} returns a ggplot2 object so users can add additional
#' customizations.
#' @param de_res Dataframe. Generated using \code{\link{diffEnrich}}
#' @param pval Numeric. Threshold for filtering pathways based on adjusted pvalue in de_res
#' @param N Numeric. Number of top pathways to plot after filtering based on pval
#'
#' @return ggplot object. If the user calls \code{plotFoldEnrich} and
#' assigns it to an object (see example) then no plot will print in viewer,
#' but if \code{plotFoldEnrich} is called without being assigned to an
#' object the plot will print to the viewer. Users can edit the ggplot object
#' as they would any other ggplot object (e.g. add title, theme, etc.).
#'
#' @details This function generates a grouped bar plot using ggplot2 and the
#' ggnewscale package. KEGG pathways are plotted on the y-axis and fold
#' enrichment is plotted on the x-axis. each KEGG pathway has a bar plotting
#' its fold enrichment in list 1 (red) and its fold enrichment in list 2 (blue).
#' The transparency of the bars correspond to the adjusted p-value for the
#' pathway's enrichment in the given list. The p-value presented as text to the
#' right of each pair of bars is the adjusted p-value associated with the
#' differential enrichment of the pathway between the two lists, and the pathways
#' are ordered from top to bottom by this p-value (i.e. smallest p-value on top
#' of plot, and largest p-value on bottom of plot).
#'
#' @import dplyr
#'         ggplot2
#'         ggnewscale
#' @importFrom reshape2 melt
#' @importFrom stats reorder
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' \dontrun{
#' plot <- plotFoldEnrichment(de_res = diffEnrich, pval = 0.05, N = 5)
#' }
plotFoldEnrichment <- function(de_res, pval, N){
  # library(dplyr)
  # library(ggplot2)
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
    dplyr::select(.data$KEGG_PATHWAY_ID, .data$KEGG_PATHWAY_description,
                  .data$fold_enrichment_list1, .data$fold_enrichment_list2,
                  .data$enrich_p_list1, .data$enrich_p_list2,
                  .data$odd_ratio, .data$diff_enrich_adjusted) %>%
    dplyr::mutate(KEGG_PATHWAY_description = sapply(strsplit(.data$KEGG_PATHWAY_description, split = " - "), function(x) x[1])) %>%
    dplyr::arrange(.data$diff_enrich_adjusted) %>%
    dplyr::filter(.data$diff_enrich_adjusted < pval) %>%
    dplyr::slice(1:N)

  ## Melt data set
  df.melt <-reshape2::melt(df, id.vars = c('KEGG_PATHWAY_ID', 'KEGG_PATHWAY_description'))

  ## Clean up melted data frame
  df.ss <- df.melt %>%
    dplyr::filter(.data$variable %in% c("fold_enrichment_list1", "fold_enrichment_list2",
                         "enrich_p_list1", "enrich_p_list2",
                         "diff_enrich_adjusted"))

  ## get vector of pvals
  pvals <- subset(df.ss, variable %in% c("enrich_p_list1", "enrich_p_list2"))

  ## Generate data set to be used for plotting
  bardat <- subset(df.ss, variable %in% c("fold_enrichment_list1", "fold_enrichment_list2")) %>%
    dplyr::mutate(alpha = log10(pvals$value),
           pvals = pvals$value) %>%
    dplyr::arrange(.data$pvals)

  ###########################################################
  # Generate plot
  ###########################################################
    # library(ggnewscale)
  # First, we'll make a plot and save it as a variable
    g <- ggplot(bardat, aes(x=stats::reorder(.data$KEGG_PATHWAY_description, -.data$pvals), y=.data$value)) +
    geom_bar(stat="identity", aes(col=.data$variable, group=.data$variable, fill=.data$pvals), position="dodge") +
    ylim(0, max(bardat$value) + 0.6) + xlab("") +
    coord_flip() +
    scale_fill_brewer(palette = "Set1",
                      name="",
                      breaks=c("fold_enrichment_list1", "fold_enrichment_list2"),
                      labels=c("Fold Enrichment in \nlist 1\n", "Fold enrichment in \nlist 2\n")) +
    scale_fill_continuous(trans = 'log10') +
    geom_text(data=subset(df.ss, df.ss$variable %in% c("diff_enrich_adjusted")),
              aes(x = .data$KEGG_PATHWAY_description, y = (max(bardat$value) + 0.3), label = round(.data$value, 4)))

  # Next, we'll take the coordinates of this layers data and match them back to the original data.
  ld <- ggplot2::layer_data(g)
  ld <- ld[, c("xmin", "xmax", "ymin", "ymax")]

  # Match back to original data
  matches <- match(ld$ymax, bardat$value)

  # Supplement with original data
  ld$pvals <- log10(bardat$pvals[matches])
  ld$descr <- bardat$KEGG_PATHWAY_description[matches]
  ld$vars <- bardat$variable[matches]

  ## Merge ld with df.ss
  df_ptext <- merge(ld, df.ss, by.x = "descr", by.y = "KEGG_PATHWAY_description")
  df_ptext <- subset(df_ptext, df_ptext$variable %in% c("diff_enrich_adjusted")) %>%
    dplyr::filter(!duplicated(.data$value))

  ## Generate finale plot
  p <- ggplot(mapping = aes(xmin = .data$xmin, xmax = .data$xmax, ymin = .data$ymin, ymax = .data$ymax)) +
    geom_rect(data = ld[ld$vars == "fold_enrichment_list1", ], aes(fill = .data$pvals)) +
    ylim(0, max(bardat$value) + 1.0) + xlab("") + ylab("Fold Enrichment") +
    scale_fill_gradient(low = "darkred", high = "transparent",
                        #trans = 'log10',
                        limits = c(min(ld$pvals), 0),
                        breaks = as.numeric(summary(ld$pvals))[c(1,2,3,5,6)],
                        labels = as.character(formatC(as.numeric(summary(bardat$pvals))[c(1,2,3,5,6)], format = "e", digits = 2)),
                        name = "P-values List 1") +
    ggnewscale::new_scale_fill() +
    geom_rect(data = ld[ld$vars == "fold_enrichment_list2", ], aes(fill = .data$pvals)) +
    scale_fill_gradient(low =  "navy", high = "transparent",
                        #trans = 'log10',
                        limits = c(min(ld$pvals), 0),
                        breaks = as.numeric(summary(ld$pvals))[c(1,2,3,5,6)],
                        labels = as.character(formatC(as.numeric(summary(bardat$pvals))[c(1,2,3,5,6)], format = 'e', digits = 2)),
                        name = "P-values List 2") +
    scale_x_continuous(breaks = seq_along(unique(ld$descr)),
                       labels = unique(ld$descr)) +
    coord_flip() + theme_bw() +
    geom_text(data=df_ptext,
              aes(x = 1:N, y = (max(bardat$value) + 0.3), label = round(.data$value, 4)))
  return(p)
}
