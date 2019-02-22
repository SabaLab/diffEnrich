#' @title get_kegg
#' @description This function connects to KEGG API, downloads, and cleans
#' ncbi gene ID data, KEGG pathway descriptions, and species specific data.
#' Currently, this function supports Human, Mouse, and Rat.
#'
#' @return
#' @export
#'
#' @examples
get_kegg <- function(species){
  # Define user's base file path
  base_path <- here::here()
  # Define base api path and define list of operations/arguments
  api_base <- "http://rest.kegg.jp/"
  op <- list("info"="info", "list"="list", "find"="find", "get"="get",
                "conv"="conv", "link"="link", "ddi"="ddi")
  db <- list("pathway"="pathway")
  org <- list("human"="hsa", "mouse"="mmu", "rat"="rno")
  # Build api paths for
  # 1) ncbi to kegg
  ncbi_to_kegg_path <- paste0(api_base, op[["conv"]], "/",
                              org[[species]], "/", "ncbi")
  # 2) kegg to pathway
  kegg_to_pathway_path <- paste0(api_base, op[["link"]], "/", db[["pathway"]],
                                 "/", org[[species]])
  # 3) pathway to species
  pathway_to_species_path <- paste0(api_base, op[["list"]], "/",
                                    db[["pathway"]],
                                 "/", org[[species]])



}
