#'
#' Process primary screening of title and abstract
#' 
#' @param search_df A `data.frame()` object of the search output.
#' @param screen_results A `data.frame()` of search screening results.
#' 
#' @returns A `data.frame()` of combined search and screening results with
#'   new variables for calculated screening results.
#' 
#' @examples
#' process_screening_primary(search_full_processed, gemini_screen_primary)
#' 
#' @export
#' 

process_screening_primary <- function(search_df,
                                      screen_results) {
  search_df |>
    dplyr::select(uid, lotid, title, abstract) |>
    dplyr::left_join(screen_results, by = "uid") |>
    dplyr::mutate(
      include_primary = dplyr::case_when(
        age_criteria & geo_criteria & study_type_criteria & topic_criteria ~ TRUE,
        .default = FALSE
      )
    )
}