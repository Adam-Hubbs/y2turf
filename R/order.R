#' Extract one combination from a turf result
#'
#' Pulls the products of a single combination out of a [turf()] result as a
#' character vector, ready to pass to [order_products()].
#'
#' @param result A data frame returned by [turf()].
#' @param rank The rank of the combination to extract. Defaults to `1`, the
#'   top combination.
#'
#' @returns A character vector of products, in the order [turf()] returned
#'   them (descending solo reach).
#' @seealso [order_products()] to order and score the extracted products.
#' @examples
#' result <- turf(
#'   am,
#'   colnames(am),
#'   num_products = 4,
#'   batch_size = 2,
#'   keep_n_at_batch = 10,
#'   num_return = 3
#' )
#' extract_combination(result)
#' extract_combination(result, rank = 2)
#' @export
extract_combination <- function(result, rank = 1) {
  rlang::check_required(result)
  rlang::check_data_frame(result)
  rlang::check_number_whole(rank, min = 1)

  missing_cols <- setdiff(c("rank", "products"), colnames(result))
  if (length(missing_cols) > 0) {
    cli::cli_abort(
      "{.arg result} must be a {.fn turf} result: missing column{?s} {.val {missing_cols}}."
    )
  }

  row <- match(rank, result$rank)
  if (is.na(row)) {
    cli::cli_abort(
      "{.arg rank} {.val {rank}} is not in {.arg result}, which has ranks {.val {result$rank}}."
    )
  }

  result$products[[row]]
}

#' Order a combination's products by reach, then marginal reach
#'
#' Orders the products of one combination greedily and reports how reach builds
#' up one product at a time. The first product in `products` is kept first: in
#' a [turf()] result it has the highest solo reach. Each later step adds the
#' remaining product that reaches the most respondents not already reached.
#' Ties are broken by solo reach, then by position in `products`.
#'
#' All measures are percentages of the respondents in `df` (0 to 100).
#'
#' @param df A data frame of 0/1 activations, with one row per respondent and
#'   one column per product, as passed to [turf()].
#' @param products A character vector of products (column names of `df`) in one
#'   combination, for example from [extract_combination()].
#'
#' @returns A tibble with one row per product, in greedy order:
#'   * `step`: position in the order.
#'   * `product`: the product added at this step.
#'   * `solo_reach`: percent of respondents the product reaches alone.
#'   * `marginal_reach`: percent of respondents the product adds beyond the
#'     earlier steps.
#'   * `total_reach`: percent of respondents reached by this and all earlier
#'     steps. The last row equals the combination's reach.
#'   * `frequency`: total activations across this and all earlier steps, as a
#'     percent of respondents. Unlike reach, it can exceed 100.
#' @seealso [extract_combination()] to get `products` from a [turf()] result.
#' @examples
#' result <- turf(
#'   am,
#'   colnames(am),
#'   num_products = 4,
#'   batch_size = 2,
#'   keep_n_at_batch = 10,
#'   num_return = 3
#' )
#' order_products(am, extract_combination(result))
#' @export
order_products <- function(df, products) {
  validate_order_args(df, products)

  mat <- as_activation_matrix(df[products])
  n <- nrow(mat)
  solo <- colSums(mat)

  chosen <- 1L
  reached <- mat[, 1] > 0
  marginal <- solo[1]

  remaining <- seq_along(products)[-1]
  while (length(remaining) > 0) {
    gain <- colSums(mat[!reached, remaining, drop = FALSE])
    best <- remaining[order(-gain, -solo[remaining], remaining)[1]]
    marginal <- c(marginal, gain[match(best, remaining)])
    chosen <- c(chosen, best)
    reached <- reached | mat[, best] > 0
    remaining <- setdiff(remaining, best)
  }

  tibble::tibble(
    step = seq_along(chosen),
    product = products[chosen],
    solo_reach = 100 * unname(solo[chosen]) / n,
    marginal_reach = 100 * unname(marginal) / n,
    total_reach = 100 * cumsum(unname(marginal)) / n,
    frequency = 100 * cumsum(unname(solo[chosen])) / n
  )
}
