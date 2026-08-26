#' Get number of unique activations (reach)
#'
#' @inheritParams turf df
#' @param cols A character vector of product/column names to find activations for
#'
#' Note: This function is for internal use and does not preform error checking.
#' It is up to the caller to ensure the products exist as columns in the dataframe.
#'
#' @return An vector representing the reach of that combination of products for each individual.
#' @export
get_activations <- function(df, cols) {
  as.integer(do.call(pmax, df[cols]) > 0)
}

#' Get frequency of activation
#'
#' Returns total frequency (total number of activations)
#'
#' @inheritParams turf df
#' @param products A Character vector of product names that correspond to column names in the activation dataframe
#'
#' @returns Integer - the total frequency
#' @export
combo_frequency <- function(df, products) {
  sum(df[products])
}

#' Get the marginal activations of a combination
#'
#' @param vec The vector of unique activations producted by [get_activations()].
#'
#' @return A positive integer representing the number of unique activations across everybody.
#'
#' Most often, this function is used on an activation dataframe that has been filtered to only contain non-activations of previous fixed combinations.
#' In that case it represents the marginal activations of the new combination.
#'
#' @export
marginal_activations <- function(vec) {
  sum(vec)
}
