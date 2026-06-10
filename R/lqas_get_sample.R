#'
#' Get LQAS sample
#' 

lqas_get_sample <- function(df,
                            dLower = 0.7, dUpper = 0.9, 
                            lot_size = 500, lot = "lotid") {
  sampframe <- sleacr::get_sample_n(
    N = lot_size, dLower = dLower, dUpper = dUpper
  )

  lots <- split(x = df, f = df[[lot]])

  lot_sizes <- lapply(X = lots, FUN = nrow)

  selection <- lapply(X = lot_sizes, FUN = sample, size = sampframe$n)

  Map(f = function(x,y) x[y, ], x = lots, y = selection)
}