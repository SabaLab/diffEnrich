#' pathEnrich
#' @description This function takes the list generated in \code{\link{get_kegg}} as well as a vector
#' of NCBI (ENTREZ) geneIDs, and identifies significantly enriched KEGG pathways using
#' a Fisher's Exact Test. Unadjusted p-values as well as FDR corrected p-values are
#' calculated.
#'
#' @param gk_obj list. Object genrated from \code{get_kegg}, or a list containing the
#' output generated from a past \code{get_kegg} call. Names of the list must match those
#' defined in \code{get_kegg}.
#' @param gene_list Vector. Vector of NCBI (ENTREZ) geneIDs
#'
#' @return enrich_table: An object of class data.frame that summarizes the results
#' of the pathway analysis.
#' @export
#' @importFrom  stats fisher.test
#' @importFrom  stats p.adjust
#' @importFrom rlang .data
#' @import dplyr
#' @import utils
#' @import org.Rn.eg.db
#' @examples
#' ## Load annotations
#' require(org.Rn.eg.db)
#' x <- org.Rn.egACCNUM
#' #Get the entrez gene identifiers that are mapped to an ACCNUM
#' mapped_genes <- mappedkeys(x)
#' gene_list <- base::sample(mapped_genes, 100, replace = FALSE)
#' kegg <- get_kegg('rat')
#' pe <- pathEnrich(gk_obj = kegg, gene_list = gene_list)
pathEnrich <- function(gk_obj, gene_list){
  ## argument check
  if(missing(gk_obj)){stop("Argument missing: gk_obj")}
  if(missing(gene_list)){stop("Argument missing: gene_list. Please provide list of ncbi geneIDs")}

  ## Prepare gene list
  gene_list <- as.integer(gene_list)

  ## prepare kegg data
  ncbi_to_kegg <- gk_obj[["ncbi_to_kegg"]]
  colnames(ncbi_to_kegg) <- c("ncbi_id", "gene")
  ncbi_to_kegg$Entry <- gsub("ncbi-geneid:","",fixed = T, ncbi_to_kegg$ncbi_id)
  kegg_to_pathway <- gk_obj[["kegg_to_pathway"]]
  colnames(kegg_to_pathway) <- c("gene", "pathway")
  ncbi_to_pathway <- merge(ncbi_to_kegg, kegg_to_pathway, by = "gene")
  ncbi_to_pathway <- ncbi_to_pathway %>%
    dplyr::select(.data$Entry, .data$pathway) %>%
    dplyr::filter(!duplicated(ncbi_to_pathway))
  pathway_to_species <- gk_obj[["pathway_to_species"]]

  ## set up enrichment
  all_KEGG <- unique(ncbi_to_pathway$Entry)
  sig_KEGG <- unique(gene_list)
  all_KEGG_cnt <- ncbi_to_pathway %>%
    dplyr::filter(.data$Entry %in% all_KEGG) %>%
    dplyr::group_by(.data$pathway) %>%
    dplyr::summarize(KEGG_cnt = length(.data$Entry))
  sig_KEGG_cnt <- ncbi_to_pathway %>%
    dplyr::filter(.data$Entry %in% sig_KEGG) %>%
    dplyr::group_by(.data$pathway) %>%
    dplyr::summarize(KEGG_sig = length(.data$Entry))

  ## Set up enrichment table
  enrich_table <- merge(all_KEGG_cnt, sig_KEGG_cnt, by = "pathway", all = TRUE)
  enrich_table$KEGG_sig[is.na(enrich_table$KEGG_sig)] = 0
  enrich_table <- enrich_table %>%
    dplyr::mutate(numTested = length(all_KEGG),
                  numSig = length(sig_KEGG),
                  expected = (.data$numSig/.data$numTested)*.data$KEGG_cnt)
  enrich_table <- merge(pathway_to_species, enrich_table, by.x = "V1", by.y = "pathway")

  ## Perform Fisher's test
  enrich_table$enrich_p <- NA
  for(i in 1:nrow(enrich_table)){
    a = enrich_table[i, "KEGG_sig"]
    b = enrich_table[i, "KEGG_cnt"] - enrich_table[i, "KEGG_sig"]
    c = enrich_table[i, "numSig"] - enrich_table[i, "KEGG_sig"]
    d = enrich_table[i, "numTested"] - enrich_table[i, "numSig"] + enrich_table[i, "KEGG_sig"]
    enrich_table$enrich_p[i] = stats::fisher.test(matrix(c(a,b,c,d), nrow = 2), alternative = "greater")$p.value
  }

  ## clean and return
  enrich_table <- enrich_table[order(enrich_table$enrich_p), ]
  enrich_table$fdr <- stats::p.adjust(enrich_table$enrich_p, method = 'BH')
  return(enrich_table)
}
