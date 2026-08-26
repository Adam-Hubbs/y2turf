# Starting from `combs` (the candidate combinations `run_batch()` returned
# for this batch -- just the new products) plus `fixed` (products already
# committed from earlier batches), repeatedly swap one product at a time --
# anywhere in the full combination, including previously-fixed products --
# keeping the best `top_n` combinations each round. The previous round's
# combos are always carried into the next round's candidate pool, so the
# kept `total_reach` values can only stay the same or improve round over
# round; the search stops once the top-`top_n` set of combinations stops
# changing. Returns the same shape as `top_n_combinations()`, plus
# `n_combinations`: the total number of swap combinations scored across all
# rounds. That count is taken straight from each round's `do_swaps()`
# output (which already de-duplicates *within* a round) without bothering
# to also net out combinations that happen to repeat across rounds or
# against `current$combos` -- overcounting slightly here doesn't matter for
# reporting purposes.
#
# @inheritParams turf df possible_products
swap_until_stable <- function(
  df,
  combs,
  fixed,
  possible_products,
  product_order,
  top_n = 3,
  starting_n = 20,
  max_rounds = 50
) {
  starting_combos <- apply(
    prepare_full_candidates(combs, fixed),
    2,
    sort_products,
    product_order = product_order
  )

  # Every product is already part of the combination, so there is nothing
  # left to swap in -- skip straight to picking the best `top_n`.
  if (nrow(starting_combos) >= length(possible_products)) {
    return(c(
      top_n_combinations(df, starting_combos, top_n),
      list(n_combinations = 0)
    ))
  }

  current <- top_n_combinations(df, starting_combos, starting_n)
  n_combinations <- 0

  for (round in seq_len(max_rounds)) {
    potential_swaps <- do_swaps(
      current$combos,
      possible_products,
      product_order
    )
    n_combinations <- n_combinations + ncol(potential_swaps)
    candidates <- cbind(current$combos, potential_swaps)
    candidates <- candidates[, !duplicated(t(candidates)), drop = FALSE]
    next_top <- top_n_combinations(df, candidates, top_n)

    if (combo_set_unchanged(current$combos, next_top$combos)) {
      return(c(next_top, list(n_combinations = n_combinations)))
    }
    current <- next_top
  }

  cli::cli_warn(
    "Swap search did not converge after {max_rounds} rounds; returning the best combinations found so far."
  )
  c(current, list(n_combinations = n_combinations))
}


#' Create matrix of potential swaps
#'
#' Creates all potential swaps we need to check from the given candidate_matrix.
#'
#' @inheritParams turf possible_products
#' @param candidate_matrix A matrix with the candidate combinations for this stage.
#' @param product_order The canonical product ordering from [determine_product_order()].
#'
#' @return A new matrix with all the potential swaps we need to check (de-duplicated).
do_swaps <- function(candidate_matrix, possible_products, product_order) {
  potential_swaps <- candidate_matrix |>
    apply(
      2,
      find_swaps,
      full_product_list = possible_products,
      simplify = FALSE
    ) |>
    (\(mats) do.call(cbind, mats))()

  ordered_swaps <- apply(
    potential_swaps,
    2,
    sort_products,
    product_order = product_order
  )
  ordered_swaps[, !duplicated(t(ordered_swaps)), drop = FALSE]
}


# For a single combination, build every "one-product-swapped" variant: each
# element of `single_combination` gets replaced, in turn, by each product in
# `full_product_list` not already present in the combination. Returns a
# matrix with the same number of rows as `single_combination` (one column
# per swap), rather than looping row-by-row and column-by-column.
find_swaps <- function(single_combination, full_product_list) {
  k <- length(single_combination)
  swappers <- setdiff(full_product_list, single_combination)
  m <- length(swappers)

  if (m == 0) {
    return(matrix(character(0), nrow = k, ncol = 0))
  }

  # k*m columns total: m swap-variants for each of the k positions
  out <- matrix(single_combination, nrow = k, ncol = k * m)
  replace_rows <- rep(seq_len(k), each = m)
  out[cbind(replace_rows, seq_len(k * m))] <- rep(swappers, times = k)

  out
}


#' Get the reach (activation count) for a product combination
#'
#' @inheritParams turf df
#' @param combination A combination of products to get the marginal activation of.
#'
#' @return An integer indicating the total number of unique activations (reach) of the combination of products.
run_swap <- function(df, combination) {
  marginal_activations(get_activations(df, combination))
}

# Score every combination (column) in `candidate_matrix` and keep the best
# `top_n`
#' @inheritParams turf df
top_n_combinations <- function(df, candidate_matrix, top_n) {
  total_reach <- apply(candidate_matrix, 2, \(products) run_swap(df, products))

  n_keep <- min(top_n, ncol(candidate_matrix))
  ranked <- order(-total_reach)[seq_len(n_keep)]

  list(
    combos = candidate_matrix[, ranked, drop = FALSE],
    total_reach = total_reach[ranked]
  )
}

#' Compare two sets of combinations for equality, ignoring column order.
#'
#' Products *within* each column are already canonicalized (see
#' `do_swaps()`), so a plain string key per column is enough to compare sets.
#' @param x_combos A combinations matrix
#' @param y_combos A combination matrix
#'
#' @return A boolean indicating whether the matricies are equivilent.
#' @export
combo_set_unchanged <- function(x_combos, y_combos) {
  key <- \(m) apply(m, 2, paste, collapse = "|")
  setequal(key(x_combos), key(y_combos))
}
