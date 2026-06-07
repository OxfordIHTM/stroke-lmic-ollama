#'
#' Screen the search articles using different LLMs
#' 
#' 

llm_screen_articles <- function(reviewer, query, type) {
  reviewer <- reviewer$set_turns(list())

  out <- reviewer$chat_structured(query, type = type)

  out |>
    dplyr::mutate(
      uid = stringr::str_extract(string = query, pattern = "[A-Z]{2}[0-9]{6}"),
      .before = age_context
    )
}


#'
#' 
#' 
#' 

llm_parallel_screen_articles <- function(reviewer, query, type) {
  ellmer::parallel_chat_structured(
    chat = reviewer, prompts = query,
    on_error = "continue", type = type
  ) |>
    dplyr::bind_rows()
}
