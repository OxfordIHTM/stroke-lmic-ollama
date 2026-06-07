#'
#' Get list of lower-middle income and low income countries based on World Bank
#' classification
#' 
#' @param wb_df
#' 

get_country_list <- function(wb_df) {
  wb_df |>
    dplyr::filter(income_group != "High income") |>
    dplyr::pull(economy) |>
    (\(x) paste0("  - ", x))() |>
    cat(sep = "\n")
}


get_all_country_list <- function(wb_df) {
  wb_df |>
    dplyr::pull(economy) |>
    paste(collapse = "; ") |>
    paste0(".")
}
