#' Title
#'
#' @return
#' @export
#'
#' @examples
pathEnrich <- function(gk_obj, gene_list){
  ## argument check
  if(missing(gk_obj)){stop("Argument missing: gk_obj")}
  if(missing(gene_list)){stop("Argument missing: gene_list. Please provide list of ncbi geneIDs")}
  ## prepare kegg data
  ncbi_to_kegg <- gk_obj[["ncbi_to_kegg"]]
  colnames(ncbi_to_kegg) <- c("ncbi_id", "gene")
  ncbi_to_kegg$Entry <- gsub("up:","",fixed = T, ncbi_to_kegg$ncbi_id)
  kegg_to_pathway <- gk_obj[["kegg_to_pathway"]]
  colnames(kegg_to_pathway) <- c("gene", "pathway")
  ncbi_to_pathway <- merge(ncbi_to_kegg, kegg_to_pathway, by = "gene")
  ncbi_to_pathway <- ncbi_to_pathway %>%
    dplyr::select(Entry, pathway) %>%
    dplyr::filter(!duplicated(ncbi_to_pathway))

}
