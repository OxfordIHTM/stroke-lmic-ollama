#'
#' Download current and historical World Bank income classification
#' 
#' @param .url
#' @param path
#' @param overwrite
#' 

wb_download_income_class <- function(.url, path, overwrite = FALSE) {
  if (!file.exists(path) | overwrite) {
    download.file(url = .url, destfile = path, mode = "wb")
  }

  path
}