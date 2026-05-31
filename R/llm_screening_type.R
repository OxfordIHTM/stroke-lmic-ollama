#'
#' Create LLM output type specification
#' 

llm_create_screening_type <- function() {
  ellmer::type_object(
    "Criteria for journal articles on stroke to include in the scoping review",
    population = ellmer::type_boolean(
      description = "Is the study about a population of adults?"
    ),
    age_group = ellmer::type_string(
      description = "Age group or age characteristics of the study population or participants. This can be terms such as adult or adults or geriatric or child or children or pediatric or paediatric. This can also be descriptions such as a range from one age to another such as 10-15 years or 10 to 15 years or 18 years and older or >= 18 years.",
      required = FALSE
    ),
    geography = ellmer::type_boolean(
      description = "Is the study conducted in a country classified as low-middle income or low income based on World Bank income classification?"
    ),
    geography_name = ellmer::type_string(
      description = "Name of the country where the study was conducted or the country or countries in which the study population or participants are from", 
      required = FALSE
    ),
    publication_type = ellmer::type_boolean(
      description = "Is the study a primary study with a research design such as a cohort study, case-control study, cross-sectional study, or interventional studies"
    ),
    publication_type_name = ellmer::type_string(
      description = "Type of publication", required = FALSE
    ),
    topic = ellmer::type_boolean(
      description = "Is the study regarding stroke burden (such as prevalence, incidence, disability-adjusted life years, quality-adjusted life years, disability, death, hospitalisation) OR types of stroke (such as ischaemic stroke, haemorrhagic stroke) OR risk factors for stroke OR interventions for stroke."
    ),
    topic_name = ellmer::type_string(
      description = "Study topic about stroke", required = FALSE
    )
  )
}