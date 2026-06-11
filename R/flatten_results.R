#'
#' Flatten results
#' 

flatten_results <- function(results_df) {
  df <- results_df |>
    dplyr::mutate(
      dplyr::across(
        .cols = c(study_type_context, topic_context),
        .fns = function(x) {
          lapply(X = x, FUN = paste, collapse = "; ") |>
            unlist()
        }
      )
    )
  
  df
}
