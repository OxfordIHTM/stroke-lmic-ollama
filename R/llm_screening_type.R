#'
#' Create LLM output type specification
#' 

llm_create_screening_type <- function() {
  ellmer::type_object(
    "A classification of journal articles on stroke",
    population = ellmer::type_boolean(
      description = "Is the study about a population of adults?"
    ),
    geography = ellmer::type_boolean(
      description = "Is the study conducted in a country classified as low-middle income or low income based on World Bank income classification?"
    ),
    publication_type = ellmer::type_boolean(
      description = "Is the study a primary study with a research design such as a cohort study, case-control study, cross-sectional study, or interventional studies"
    ),
    topic = ellmer::type_boolean(
      description = "Is the study regarding stroke burden (such as prevalence, incidence, disability-adjusted life years, quality-adjusted life years, disability, death, hospitalisation) OR types of stroke (such as ischaemic stroke, haemorrhagic stroke) OR risk factors for stroke OR interventions for stroke."
    )
  )
}