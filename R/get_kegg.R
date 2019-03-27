#' @title get_kegg
#' @description This function connects to the KEGG API, downloads, and cleans
#' ncbi gene ID data, KEGG pathway descriptions, and species specific data.
#' Currently, this function supports Human, Mouse, and Rat. Files will be
#' written to the working directory.
#'
#' @param species character. The species to use in kegg data pull
#'
#' @return kegg_out: A named list of the data pulled from kegg api when the
#' function was run. This may be different if the function is run at
#' different times. For reproducible results, use text files generated
#' by function that include the date they were pulled. Use findFile = TRUE
#' to find location of data in expected directory.
#' @export
#' @importFrom here here
#' @import utils
#' @importFrom stringr str_extract
#'
#' @examples
#' kegg <- get_kegg(species = "human")
#' \dontrun{
#' kegg <- get_kegg(species = "mouse")
#' }
#'
get_kegg <- function(species){
  options(stringsAsFactors = F)
  # Define user's base file path
  base_path <- here::here()
  flist <- list.files(base_path)
  if(missing(species)){stop("Must choose one of the 3 species options: human, mouse, rat")}
  else {
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
    # 4) pathway to kegg release
    pathway_to_kegg_release <- paste0(api_base, op[["info"]], "/",
                                      "kegg")
    ## api pull
    kegg_release <- utils::read.table(file = pathway_to_kegg_release,
                                      fill = TRUE,
                                      sep = "\t",
                                      quote = "")[2, 1]
    kegg_release <- stringr::str_extract(kegg_release, ".{0,0}Release.{0,30}")
    kegg_release <- gsub(",", "", kegg_release, fixed = T)
    kegg_release <- gsub(" ", "_", kegg_release, fixed = T)
    kegg_release <- gsub("/", "_", kegg_release, fixed = T)
    if (sum(flist %in% c(paste("ncbi_to_kegg",Sys.Date(), kegg_release, ".txt",sep=""),
                         paste("kegg_to_pathway",Sys.Date(), kegg_release, ".txt",sep=""),
                         paste("pathway_to_species",Sys.Date(), kegg_release, ".txt",sep="")))>0){
      stop("These files already exist in your working directory.")
    }
    else {
      ncbi_to_kegg <- utils::read.table(file = ncbi_to_kegg_path,
                                        fill = TRUE,
                                        sep = "\t",
                                        quote = "")
      kegg_to_pathway <- utils::read.table(file = kegg_to_pathway_path,
                                           fill = TRUE,
                                           sep = "\t",
                                           quote = "")
      pathway_to_species <- utils::read.table(file = pathway_to_species_path,
                                              fill = TRUE,
                                              sep = "\t",
                                              quote = "")

      message("3 data sets will be written as tab delimited text files")
      message("File location: ", here::here())
      message("Kegg Release: ", kegg_release)
      ## Since the kegg api will pull the most updated verions
      # write out tables for reproduciblity.
      utils::write.table(ncbi_to_kegg,
                         file=paste(base_path,"/ncbi_to_kegg",Sys.Date(), kegg_release, ".txt",sep=""),
                         sep="\t",
                         row.names=FALSE,
                         col.names=FALSE,
                         quote=FALSE)
      utils::write.table(kegg_to_pathway,
                         file=paste(base_path,"/kegg_to_pathway",Sys.Date(), kegg_release, ".txt",sep=""),
                         sep="\t",
                         row.names=FALSE,
                         col.names=FALSE,
                         quote=FALSE)
      utils::write.table(pathway_to_species,
                         file=paste(base_path,"/pathway_to_species",Sys.Date(), kegg_release, ".txt",sep=""),
                         sep="\t",
                         row.names=FALSE,
                         col.names=FALSE,
                         quote=FALSE)
      kegg_out <- list("ncbi_to_kegg" = ncbi_to_kegg,
                       "kegg_to_pathway" = kegg_to_pathway,
                       "pathway_to_species" = pathway_to_species)
      return(kegg_out)
    }
  }
}
