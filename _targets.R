# General Targets Workflow Template --------------------------------------------


## Load libraries and custom functions ----
suppressPackageStartupMessages(source("packages.R"))
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)


## Data targets ----
data_targets <- tar_plan(
  tar_target(
    name = ris_file_paths,
    command = list.files(path = "data-raw", pattern = ".ris", full.names = TRUE)
  ),
  tar_target(
    name = ris_all,
    command = readLines(ris_file_paths),
    pattern = map(ris_file_paths)
  ),
  tar_target(
    name = search_full_ris,
    command = synthesisr::read_refs(filename = ris_file_paths),
    pattern = map(ris_file_paths),
    iteration = "list"
  ),
  tar_target(
    name = search_full_raw,
    command = synthesisr::read_refs(filename = ris_all_file)
  ),
  retraction_watch_data_url = "https://gitlab.com/crossref/retraction-watch-data/-/raw/main/retraction_watch.csv",
  tar_target(
    name = retraction_watch_data_download_csv_file,
    command = retraction_download_data(
      .url = retraction_watch_data_url, path = "data/retraction_watch.csv"
    )
  ),
  tar_target(
    name = retraction_watch_data,
    command = retraction_load_data(
      path = retraction_watch_data_download_csv_file
    )
  ),
  wb_income_class_current_url = "https://ddh-openapi.worldbank.org/resources/DR0095333/download",
  wb_income_class_historical_url = "https://ddh-openapi.worldbank.org/resources/DR0095334/download",
  tar_target(
    name = wb_income_class_current_download_file,
    command = wb_download_income_class(
      .url = wb_income_class_current_url,
      path = "data-raw/wb_income_class_current.xlsx"
    )
  ),
  tar_target(
    name = wb_income_class_current_raw,
    command = openxlsx::read.xlsx(
      xlsxFile = wb_income_class_current_download_file
    )
  ),
  tar_target(
    name = wb_income_class_historical_download_file,
    command = wb_download_income_class(
      .url = wb_income_class_historical_url,
      path = "data-raw/wb_income_class_historical.xlsx"
    )
  ),
  tar_target(
    name = wb_income_class_historical_raw,
    command = openxlsx::read.xlsx(
      xlsxFile = wb_income_class_historical_download_file,
      sheet = "Country Analytical History", startRow = 12,
      colNames = FALSE, skipEmptyRows = FALSE, skipEmptyCols = FALSE
    )
  )
)


## Processing targets ----
processing_targets <- tar_plan(
  tar_target(
    name = search_full_deduplicated,
    command = synthesisr::deduplicate(
      data = search_full_raw, match_by = "title", method = "string_osa"
    )
  ),
  tar_target(
    name = search_full_no_retractions,
    command = remove_retracted(
      search_df = search_full_deduplicated, 
      retraction_df = retraction_watch_data
    )
  ),
  tar_target(
    name = wb_income_class_current_processed,
    command = wb_income_class_process(
      wb_df = wb_income_class_current_raw, data_type = "current"
    )
  ),
  tar_target(
    name = wb_income_class_historical_processed,
    command = wb_income_class_process(
      wb_df = wb_income_class_historical_raw, data_type = "historical"
    )
  ),
  tar_target(
    name = search_full_processed,
    command = process_search(search_full_no_retractions)
  ),
  tar_target(
    name = search_full_processed_flattened,
    command = flatten_search(search_full_processed)
  ),
  tar_target(
    name = search_title,
    command = get_title(search_full_processed)
  ),
  tar_target(
    name = search_abstract,
    command = get_abstract(search_full_processed)
  )
)


## Prompt targets ----
prompt_targets <- tar_plan(
  tar_target(
    name = wb_lmic_lic_prompt,
    command = get_country_list(wb_df = wb_income_class_current_processed)
  ),
  tar_target(
    name = screening_context_prompt,
    command = create_screening_context_prompt(wb_lmic_lic_prompt)
  ),
  tar_target(
    name = screening_prompt,
    command = create_screening_prompt(
      search_title = search_title, search_abstract = search_abstract
    )
  )
)


## Ollama Gemma4 LLM targets ----
gemma_ollama_targets <- tar_plan(
  gemma_model = "gemma4:31b",
  tar_target(
    name = gemma_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, model = gemma_model
    )
  ),
  tar_target(
    name = gemma_test_screen_primary,
    command = gemma_screen_articles(
      gemma_reviewer = gemma_reviewer,
      query = screening_prompt
    ),
    pattern = slice(screening_prompt, 1:20)
  )
)


## Ollama Deepseek R1 LLM targets ----
deepseek_ollama_targets <- tar_plan(
  deepseek_model = "deepseek-r1:671b",
  tar_target(
    name = deepseek_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, model = deepseek_model
    )
  ),
  tar_target(
    name = deepseek_test_screen_primary,
    command = deepseek_screen_articles(
      deepseek_reviewer = deepseek_reviewer,
      query = screening_prompt
    ),
    pattern = slice(screening_prompt, 1:20)
  )
)



## Analysis targets ----
analysis_targets <- tar_plan(
  
)


## Output targets ----
output_targets <- tar_plan(
  tar_target(
    name = ris_all_file,
    command = output_ris_file(ris = ris_all, dest = "data/search_all.ris")
  ),
  tar_target(
    name = search_full_processed_flattened_csv,
    command = output_csv_file(
      df = search_full_processed_flattened,
      path = "data/search_full_processed_flattened.csv"
    )
  )
)


## Reporting targets ----
report_targets <- tar_plan(
  
)


## Deploy targets ----
deploy_targets <- tar_plan(
  
)


## List targets ----
all_targets()
