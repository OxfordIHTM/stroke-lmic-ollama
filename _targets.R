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
    command = read_ris_file(ris_file = ris_all_file)
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
    name = search_id,
    command = get_id(search_full_processed)
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
llm_prompt_targets <- tar_plan(
  tar_target(
    name = country_list_prompt,
    command = get_all_country_list(wb_df = wb_income_class_current_processed)
  ),
  tar_target(
    name = wb_mic_lic_prompt,
    command = get_country_list(wb_df = wb_income_class_current_processed)
  ),
  tar_target(
    name = screening_context_prompt,
    command =  interpolate_screening_context_prompt(wb_mic_lic_prompt),
    cue = tar_cue("always")
  ),
  tar_target(
    name = screening_prompt,
    command = interpolate_screening_prompt(
      search_id = search_id,
      search_title = search_title, 
      search_abstract = search_abstract
    )
  ),
  tar_target(
    name = screening_prompt_batched,
    command = batch_screening_prompt(
      screening_prompt = screening_prompt,
      search_full_processed = search_full_processed
    )
  ),
  tar_target(
    name = screening_output_type,
    command = llm_create_screening_type()
  ),
  tar_target(
    name = llm_parameters,
    command = ellmer::params(
        temperature = 0.3,
        top_p = 0.95,
        top_k = 64,
        reasoning_effort = "low",
        reasoning_tokens = 0
    )
)


## Ollama gemma4 LLM targets ----
gemma_ollama_targets <- tar_plan(
  gemma_model = "gemma4:31b",
  tar_target(
    name = gemma_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, 
      model = gemma_model,
      params = llm_parameters
    )
  ),
  tar_target(
    name = gemma_test_screen_primary,
    command = llm_screen_articles(
      reviewer = gemma_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = slice(screening_prompt, 1:20)
  ),
  tar_target(
    name = gemma_screen_primary,
    command = llm_screen_articles(
      reviewer = gemma_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = map(screening_prompt)
  ),
  tar_target(
    name = gemma_screen_primary_processed,
    command = process_screening_primary(
      search_df = search_full_processed,
      screen_results = gemma_screen_primary
    )
  )
)


## Ollama deepseek-r1 LLM targets ----
deepseek_ollama_targets <- tar_plan(
  deepseek_model = "deepseek-r1:70b",
  tar_target(
    name = deepseek_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, model = deepseek_model
    )
  ),
  tar_target(
    name = deepseek_test_screen_primary,
    command = llm_screen_articles(
      reviewer = deepseek_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = slice(screening_prompt, 1:20)
  ),
  tar_target(
    name = deepseek_screen_primary,
    command = llm_screen_articles(
      reviewer = deepseek_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = map(screening_prompt)
  ),
  tar_target(
    name = deepseek_screen_primary_processed,
    command = process_screening_primary(
      search_df = search_full_processed,
      screen_results = deepseek_screen_primary
    )
  )
)


## Ollama gpt-oss LLM targets ----
gpt_ollama_targets <- tar_plan(
  gpt_model = "gpt-oss:120b",
  tar_target(
    name = gpt_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, model = gpt_model
    )
  ),
  tar_target(
    name = gpt_test_screen_primary,
    command = llm_screen_articles(
      reviewer = gpt_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = slice(screening_prompt, 1:20)
  ),
  tar_target(
    name = gpt_screen_primary,
    command = llm_screen_articles(
      reviewer = gpt_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = map(screening_prompt)
  ),
  tar_target(
    name = gpt_screen_primary_processed,
    command = process_screening_primary(
      search_df = search_full_processed,
      screen_results = gpt_screen_primary
    )
  ),
  tar_target(
    name = gpt_screen_primary_processed_flattened,
    command = flatten_search(processed_df = gpt_screen_primary_processed)
  )
)


## Ollama qwen3.5 LLM targets ----
qwen_ollama_targets <- tar_plan(
  qwen_model = "qwen3.5:122b",
  tar_target(
    name = qwen_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, model = qwen_model
    )
  ),
  tar_target(
    name = qwen_test_screen_primary,
    command = llm_screen_articles(
      reviewer = qwen_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = slice(screening_prompt, 1:20)
  ),
  tar_target(
    name = qwen_screen_primary,
    command = llm_screen_articles(
      reviewer = qwen_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = map(screening_prompt)
  ),
  tar_target(
    name = qwen_screen_primary_processed,
    command = process_screening_primary(
      search_df = search_full_processed,
      screen_results = qwen_screen_primary
    )
  )
)


## Ollama llama4 LLM targets ----
llama_ollama_targets <- tar_plan(
  llama_model = "llama4:16x17b",
  tar_target(
    name = llama_reviewer,
    command = ellmer::chat_ollama(
      system_prompt = screening_context_prompt, model = llama_model
    )
  ),
  tar_target(
    name = llama_test_screen_primary,
    command = llm_screen_articles(
      reviewer = llama_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = slice(screening_prompt, 1:20)
  ),
  tar_target(
    name = llama_screen_primary,
    command = llm_screen_articles(
      reviewer = llama_reviewer,
      query = screening_prompt,
      type = screening_output_type
    ),
    pattern = map(screening_prompt)
  ),
  tar_target(
    name = llama_screen_primary_processed,
    command = process_screening_primary(
      search_df = search_full_processed,
      screen_results = llama_screen_primary
    )
  )
)




## Analysis targets ----
analysis_targets <- tar_plan(
  
)


## LQAS testing targets ----
lqas_targets <- tar_plan(
  lqas_lower = 0.7,
  lqas_upper = 0.9,
  tar_target(
    name = lqas_sample,
    command = lqas_get_sample(
      df = search_full_processed, dLower = lqas_lower, dUpper = lqas_upper
    )
  )
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
  ),
  tar_target(
    name = gpt_screen_primary_processed_flattened_csv,
    command = output_csv_file(
      df = gpt_screen_primary_processed_flattened,
      path = "data/gpt_screen_primary_processed_flattened.csv"
    )
  )
)


## Reporting targets ----
report_targets <- tar_plan(
  
)


## Deploy targets ----
deploy_targets <- tar_plan(
  
)


## Set seed ----
set.seed(1977)


## List targets ----
all_targets()
