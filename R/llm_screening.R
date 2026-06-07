#'
#' Screen the search articles using different LLMs
#' 
#' 

llm_screen_articles <- function(reviewer, query, type) {
  out <- reviewer$chat_structured(query, type = type)

  # col_names <- names(out)

  # matrix(data = out, nrow = 1, ncol = 8, byrow = TRUE) |>
  #   data.frame() |>
  #   stats::setNames(nm = col_names)

  out
}


llm_parallel_screen_articles <- function(reviewer, query, type) {
  ellmer::parallel_chat_structured(
    chat = reviewer, prompts = as.list(query),
    on_error = "continue", type = type
  )
}
