#' Find the respondents a combination reaches
#'
#' A respondent is reached by a combination if they are activated by at least
#' one of its products.
#'
#' This is a low-level helper and does no input checking: `cols` must be
#' columns of `mat` containing only `0` and `1`.
#'
#' @param mat A data frame or matrix of activations, with one row per
#'   respondent and one column per product.
#' @param cols A character vector of products (column names of `mat`).
#'
#' @returns A logical vector with one element per row of `mat`: `TRUE` if that
#'   respondent is reached.
#' @seealso [marginal_activations()] to count the respondents reached.
#' @examples
#' reached <- get_activations(am, c("northwind", "may"))
#' head(reached)
#' @export
get_activations <- function(mat, cols) {
  rowSums(mat[, cols, drop = FALSE]) > 0
}

#' Count a combination's total activations
#'
#' Frequency is the total number of activations across a combination's
#' products. Unlike reach, a respondent activated by several products counts
#' once for each.
#'
#' @param df A data frame or matrix of activations, with one row per respondent
#'   and one column per product.
#' @param products A character vector of products (column names of `df`).
#'
#' @returns A single number: the total frequency.
#' @examples
#' combo_frequency(am, c("northwind", "may"))
#' @export
combo_frequency <- function(df, products) {
  sum(df[, products, drop = FALSE])
}

#' Count the respondents reached
#'
#' Counts the respondents marked as reached by [get_activations()]. On the full
#' data this is a combination's reach. On data limited to respondents not
#' already reached by some other products, it is the combination's marginal
#' reach: how many new respondents it adds.
#'
#' @param vec A logical vector from [get_activations()].
#'
#' @returns A single integer: the number of respondents reached.
#' @examples
#' # Reach of a combination
#' marginal_activations(get_activations(am, c("northwind", "may")))
#'
#' # Respondents "may" adds beyond those "northwind" already reaches
#' not_reached <- am[!get_activations(am, "northwind"), ]
#' marginal_activations(get_activations(not_reached, "may"))
#' @export
marginal_activations <- function(vec) {
  sum(vec)
}

# jarl-ignore unused_function: Used in benchmarking
apply_get_activations <- function(mat, combos) {
  vapply(
    combos,
    \(cols) get_activations(mat, cols) |> marginal_activations(),
    integer(1)
  )
}
