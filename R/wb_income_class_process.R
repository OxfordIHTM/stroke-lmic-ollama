#'
#' Process current World Bank income classification data
#' 

wb_income_class_process <- function(wb_df, 
                                    data_type = c("current", "historical")) {
  data_type <- match.arg(data_type)

  if (data_type == "current") {
    df <- wb_df |>
      stats::setNames(
        nm = c("economy", "iso3c", "region", "income_group", "lending_category")
      ) |>
      (\(x) x[1:218, ])() |>
      tibble::as_tibble()
  } else {
    df <- wb_df |>
      (\(x) x[c(1:218, 222:227), 1:40])() |>
      stats::setNames(
        nm = c(
          "iso3c", "economy", "FY89", "FY90", "FY91", "FY92", "FY93", "FY94",
          "FY95", "FY96", "FY97", "FY98", "FY99", "FY00", "FY01", "FY02",
          "FY03", "FY04", "FY05", "FY06", "FY07", "FY08", "FY09", "FY10",
          "FY11", "FY12", "FY13", "FY14", "FY15", "FY16", "FY17", "FY18",
          "FY19", "FY20", "FY21", "FY22", "FY23", "FY24", "FY25", "FY26"
        )
      ) |>
      dplyr::mutate(
        dplyr::across(
          .cols = 3:40, 
          .fns = function(x) ifelse(x == "..", NA_character_, x)
        )
      )
  }

  df
}



