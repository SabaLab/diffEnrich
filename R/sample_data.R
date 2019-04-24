#' @title geneLists
#'
#' @description This is a \code{list} object that contains the list background
#' genes and significant genes used in pathway enrichment. This object is
#' mostly meant for running examples and vignettes.
#'
#' @format A \code{list} with two names items which are:
#' \describe{
#' \item{background}{List of ENTREZ gene IDs that will considered background }
#' \item{sigGenes}{ List of ENTREZ gene IDs that were significant}
#' }
"geneLists"


#' @title kegg
#'
#' @description This is a \code{list} object that contains the output generated
#' from the \code{get_kegg} function. This object is
#' mostly meant for running examples and vignettes.
#'
#' @format A \code{list} with three names items which are:
#' \describe{
#' \item{kegg_to_pathway}{List of kegg IDs mapped to pathway IDs }
#' \item{ncbi_to_kegg}{ List of ENTREZ gene IDs that map to kegg IDs}
#' \item{pathway_to_species}{ List of pathways IDs that map to rat pathways}
#' }
"kegg"
