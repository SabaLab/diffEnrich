#' @title get_kegg
#' @description This function calls an internal helper function that connects to the KEGG API, downloads, and stores
#' ncbi gene ID data, KEGG pathway descriptions, and species specific data.
#' Currently, this function supports Human, Mouse, and Rat. Files will be
#' written to the working directory unless otherwise specified by the user.
#'
#' @param species character. The species to use in kegg data pull
#' @param path character. A character string describing the path to write out KEGG
#' API data sets. If not provided, defaults to current working directory.
#'
#' @details the \code{get_kegg} function is used to connect to the KEGG REST API
#' and download the data sets required to perform downstream analysis.
#' Currently, this function supports three species, and recognizes the KEGG code
#' for Homo sapiens (‘hsa’), Mus musculus (‘mmu’), and Rattus norvegicus (‘rno’).
#' For a given species, three data sets are generated: 1) Because the user must
#' provide their own gene lists in downstream analysis using ENTREZ gene IDs,
#' the data set maps NCBI/ENTREZ gene IDs to KEGG gene IDs, 2) a data set that
#' maps KEGG gene IDs to their respective KEGG pathway IDs, and 3) a data set that
#' maps KEGG pathway IDs to their respective pathway descriptions.  This function
#' allows the user save versioned (based on KEGG release) and time-stamped text
#' files of the three data sets described above. In addition to these flat files,
#' \code{get_kegg()} will also create a named list with the three relevant KEGG
#' data sets. The names of this list will describe the data set.
#'
#' @return kegg_out: A named list of the data pulled from kegg api when the
#' function was run. This may be different if the function is run at
#' different times. For reproducible results, use text files generated
#' by function that include the date they were pulled.
#'
#' \describe{
#'   \item{ncbi_to_kegg}{ncbi_to_kegg mappings as class data.frame}
#'   \item{kegg_to_pathway}{kegg_to_pathway mappings as class data.frame}
#'   \item{pathway_to_species}{pathway_to_species mappings as class data.frame}
#'   }
#'
#' @export
#' @importFrom here here
#'
#' @examples
#' \dontrun{
#' kegg <- get_kegg(species = "rno")
#' }
#' \dontrun{
#' kegg <- get_kegg(species = "mmu", path = "usr/data/out/")
#' }
#'
get_kegg <- function(species, path = NULL){
  ## API pull if path = NULL
  if(is.null(path)){
    wkd <- here::here()
    res <- .api_pull(species, path = wkd)
  } else {
    # API pull with user's path
    res <- .api_pull(species, path = path)
  }
  return(res)
}



#' @title .api_pull
#' @description This function connects to the KEGG API, downloads, and cleans
#' ncbi gene ID data, KEGG pathway descriptions, and species specific data.
#' Currently, this function supports Human, Mouse, and Rat. Files will be
#' written to the working directory unless otherwise specified by the user.
#'
#' @param species character. The species to use in kegg data pull
#' @param path character. A character string describing the path to write out KEGG
#' API data sets. If not provided, defaults to current working directory.
#'
#' @return kegg_out: A named list of the data pulled from kegg api when the
#' function was run. This may be different if the function is run at
#' different times. For reproducible results, use text files generated
#' by function that include the date they were pulled.
#'
#' @importFrom here here
#' @import utils
#' @importFrom stringr str_extract
#'
.api_pull <- function(species, path = path){
  options(stringsAsFactors = F)
  ## Argument checks
  if(missing(species)){stop("Must choose one of the 3 species options: human, mouse, rat")}
  if(missing(species) | !(species %in% c('hsa','mmu','rno'))){stop("Must choose one of the 3 species options: human: use 'hsa', mouse: use 'mmu', rat: use rno")}

  # Define base api path and define list of operations/arguments
  api_base <- "http://rest.kegg.jp/"
  op <- list("info"="info", "list"="list", "find"="find", "get"="get",
             "conv"="conv", "link"="link", "ddi"="ddi")
  db <- list("pathway"="pathway")
  org <- list("hsa"="hsa", "mmu"="mmu", "rno"="rno")

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
  find_files <- c(paste("ncbi_to_kegg",Sys.Date(), kegg_release, ".txt",sep=""),
                  paste("kegg_to_pathway",Sys.Date(), kegg_release, ".txt",sep=""),
                  paste("pathway_to_species",Sys.Date(), kegg_release, ".txt",sep=""))

  # Define user's base file path
  flist <- list.files(path)
  # Check is files exist
  if (sum(flist %in% find_files)>0){message("These files already exist in your working directory. New files will not be generated.")
    # If files exist will do an api pull to generate object but won't write out new files
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

    message("Kegg Release: ", kegg_release)
    kegg_out <- list("ncbi_to_kegg" = ncbi_to_kegg,
                     "kegg_to_pathway" = kegg_to_pathway,
                     "pathway_to_species" = pathway_to_species)
  }
  # If files do not exist, will do an api pull and generate txt files in wkdir
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
    message("File location: ", path)
    message("Kegg Release: ", kegg_release)
    # write files
    utils::write.table(ncbi_to_kegg,
                       file=paste(path,"/ncbi_to_kegg",Sys.Date(), kegg_release, ".txt",sep=""),
                       sep="\t",
                       row.names=FALSE,
                       col.names=FALSE,
                       quote=FALSE)
    utils::write.table(kegg_to_pathway,
                       file=paste(path,"/kegg_to_pathway",Sys.Date(), kegg_release, ".txt",sep=""),
                       sep="\t",
                       row.names=FALSE,
                       col.names=FALSE,
                       quote=FALSE)
    utils::write.table(pathway_to_species,
                       file=paste(path,"/pathway_to_species",Sys.Date(), kegg_release, ".txt",sep=""),
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
