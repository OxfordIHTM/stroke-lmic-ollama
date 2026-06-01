#'
#' Create screening prompt
#' 

create_screening_prompt <- function(search_title, search_abstract) {
  paste0(
    " ", search_title, ".\n\n",
    "The abstract of the study is ", search_abstract, "."
  )
} 


#'
#' Interpolate screening prompt
#' 

interpolate_screening_prompt <- function(search_title, search_abstract) {
  ellmer::interpolate_file(
    path = "prompts/prompt-input-title-abstract.md",
    search_title = search_title,
    search_abstract = search_abstract
  )
}
