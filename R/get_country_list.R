#'
#' Get list of lower-middle income and low income countries based on World Bank
#' classification
#' 
#' @param wb_df
#' 

get_country_list <- function(wb_df) {
  x <- wb_df |>
    dplyr::filter(income_group != "High income") |>
    dplyr::pull(economy)

  x[x == "Congo, Dem. Rep."]          <- "Democratic Republic of the Congo"
  x[x == "Congo, Rep."]               <- "Congo-Brazzaville"
  x[x == "Egypt, Arab Rep."]          <- "Egypt"
  x[x == "Gambia, The"]               <- "Gambia"
  x[x == "Iran, Islamic Rep."]        <- "Iran"
  x[x == "Korea, Dem. People's Rep."] <- "North Korea"
  x[x == "Kyrgyz Republic"]           <- "Kyrgyzstan"
  x[x == "Lao PDR"]                   <- "Laos"
  x[x == "Micronesia, Fed. Sts."]     <- "Micronesia"
  x[x == "Somalia, Fed. Rep."]        <- "Somalia"
  x[x == "Syrian Arab Republic"]      <- "Syria"
  x[x == "Yemen, Rep."]               <- "Yemen"
  
  x |>
    (\(x) paste0("\n- ", x))() |>
    paste(collapse = "  ")
}


get_all_country_list <- function(wb_df) {
  wb_df |>
    dplyr::pull(economy) |>
    paste(collapse = "; ") |>
    paste0(".")
}
