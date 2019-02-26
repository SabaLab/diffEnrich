#' @title get_kegg
#' @description This function connects to the KEGG API, downloads, and cleans
#' ncbi gene ID data, KEGG pathway descriptions, and species specific data.
#' Currently, this function supports Human, Mouse, and Rat.
#'
#' @return kegg_out: A named list of the data pulled from kegg api when the
#' function was run. This may be different if the function is run at
#' different times. For reproducible results, use text files generated
#' by function that include the date they were pulled.
#' @export
#'
#' @examples
#' kegg <- get_kegg(species = "human")
#' \dontrun{
#' kegg <- get_kegg(species = "mouse")
#' }
#'
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
                              org[[species]], "/", "ncbi-geneid")
  # 2) kegg to pathway
  kegg_to_pathway_path <- paste0(api_base, op[["link"]], "/", db[["pathway"]],
                                 "/", org[[species]])
  # 3) pathway to species
  pathway_to_species_path <- paste0(api_base, op[["list"]], "/",
                                    db[["pathway"]],
                                 "/", org[[species]])
  ## api pull
  ncbi_to_kegg <- read.table(file = ncbi_to_kegg_path,
                             fill = TRUE,
                             sep = "\t",
                             quote = "")
  kegg_to_pathway <- read.table(file = kegg_to_pathway_path,
                             fill = TRUE,
                             sep = "\t",
                             quote = "")
  pathway_to_species <- read.table(file = pathway_to_species_path,
                             fill = TRUE,
                             sep = "\t",
                             quote = "")
  ## Since the kegg api will pull the most updated verions
  # write out tables for reproduciblity.
  write.table(ncbi_to_kegg,
              file=paste(base_path,"/ncbi_to_kegg",Sys.Date(),".txt",sep=""),
              sep="\t",
              row.names=FALSE,
              col.names=FALSE,
              quote=FALSE)
  write.table(kegg_to_pathway,
              file=paste(base_path,"/kegg_to_pathway",Sys.Date(),".txt",sep=""),
              sep="\t",
              row.names=FALSE,
              col.names=FALSE,
              quote=FALSE)
  write.table(pathway_to_species,
              file=paste(base_path,"/pathway_to_species",Sys.Date(),".txt",sep=""),
              sep="\t",
              row.names=FALSE,
              col.names=FALSE,
              quote=FALSE)
  kegg_out <- list("ncbi_to_kegg" = ncbi_to_kegg,
                   "kegg_to_pathway" = kegg_to_pathway,
                   "pathway_to_species", pathway_to_species)
return(kegg_out)
}
