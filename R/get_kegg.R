#' @title get_kegg
#' @description This function connects to KEGG API, downloads, and cleans
#' ncbi gene ID data, KEGG pathway descriptions, and species specific data.
#' Currently, this function supports Human, Mouse, and Rat.
#'
#' @return
#' @export
#'
#' @examples
get_kegg <- function(){
  # Define base api path and define list of operations/arguments
  api_base <- "http://rest.kegg.jp/"
  op <- as.list("info"="info", "list"="list", "find"="find", "get"="get",
                "conv"="conv", "link"="link", "ddi"="ddi")
  db <- as.list("pathway"="pathway")
  org <- as.list("human"="hsa", "mouse"="mmu", "rat"="rno")


}
