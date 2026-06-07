#'
#' Screen the search articles using different LLMs
#' 
#' 

llm_screen_articles <- function(reviewer, query, type) {
  reviewer <- reviewer$set_turns(list())

  reviewer$chat_structured(query, type = type, echo = "none", convert = FALSE)
}


#'
#' 
#' 
#' 

llm_parallel_screen_articles <- function(reviewer, query, type) {
  reviewer <- reviewer$set_turns(list())

  ellmer::parallel_chat_structured(
    chat = reviewer, prompts = query,
    on_error = "continue", type = type
  ) |>
    dplyr::bind_rows()
}
