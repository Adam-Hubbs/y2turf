get_activations <- function(df, cols) {
  as.integer(do.call(pmax, df[cols]) > 0)
}

#' Get frequency of activation
#'
#' Returns total frequency (total number of activations)
#'
#' @param df The activation dataframe
#' @param products A Character vector of product names that correspond to column names in the activation dataframe
#'
#' @returns Integer - the total frequency
combo_frequency <- function(df, products) {
  sum(df[products])
}

marginal_activations <- function(vec) {
  sum(vec)
}
