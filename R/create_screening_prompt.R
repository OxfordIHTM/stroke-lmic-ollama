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


#'
#' Interpolate screening context prompt
#' 

interpolate_screening_context_prompt <- function(wb_lmic_lic_prompt) {
  ellmer::interpolate_file(
    path = "prompts/prompt-screening-context.md",
    wb_lmic_lic_prompt = wb_lmic_lic_prompt
  )
}
