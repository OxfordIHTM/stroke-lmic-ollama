#'
#' Get identifier of articles
#' 
#' @param processed_df A `data.frame()`` object of the processed search output.
#' 
#' @returns A character vector of titles of articles from processed search
#'   data
#' 
#' @examples
#' get_id(search_full_processed)
#' 
#' @export
#' 

get_id <- function(processed_df) {
  processed_df |>
    (\(x) x$uid)()
}
