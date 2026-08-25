#' Sort the resut from turf
#'
#' Sorts the result on both dimensions. Sorts products by reach (ties are broken by frequency, then initial position)
#' Sorts rows by total reach, then by frequency
#'
#' Returns the sorted result matrix
collect_top_combos <- function(
  df,
  possible_products,
  fixed_before_final_batch,
  final_batch_result,
  num_return
) {
  # `final_batch_result$reach` is *marginal* reach, already computed once by
  # `run_batch()` -- but since every candidate here shares the same
  # `fixed_before_final_batch`, marginal and total reach differ only by a
  # constant offset (the reach `fixed_before_final_batch` gets on its own),
  # so their orderings are identical. That means we can find the
  # rank-`n_return` threshold directly from `reach`, with zero
  # `get_activations()` calls, and only build product sets / compute real
  # activations for the small qualifying subset that survives the cutoff --
  # not the full candidate pool. This matters once that pool is large --
  # e.g. `batch_size == num_products` against a sizeable product universe.
  marginal_reach <- final_batch_result$reach
  n_return <- min(num_return, length(marginal_reach))

  threshold <- reach_threshold_at_rank(marginal_reach, n_return)
  qualified <- which(marginal_reach >= threshold)

  combos_list <- purrr::map(
    qualified,
    \(i) c(fixed_before_final_batch, final_batch_result$combos[, i])
  )

  total_reach <- purrr::map_int(
    combos_list,
    \(products) sum(get_activations(df, products))
  )
  frequency <- purrr::map_dbl(
    combos_list,
    \(products) combo_frequency(df, products)
  )

  ranked <- order(-total_reach, -frequency)[seq_len(n_return)]

  solo_counts <- colSums(df[possible_products])

  purrr::map(seq_along(ranked), \(rank) {
    idx <- ranked[rank]
    sorted_products <- sort_products(
      combos_list[[idx]],
      solo_counts,
      possible_products
    )
    tibble::tibble(
      rank = rank,
      products = list(sorted_products),
      total_reach = total_reach[idx]
    )
  }) |>
    purrr::list_rbind()
}


#' Find product sort order
#'
#' Returns the canonical ordering
product_sort_order <- function(products, solo_counts, possible_products) {
  order(-solo_counts[products], match(products, possible_products))
}

#' Sort Products
#'
#' Sorts the matrix so that products are in the correct order. Orders by reach.
#'
#' @param df The activation dataframe
#' @param candidate_matrix The matrix to sort
#' @param possible_products The products in the universe
#'
#' @returns The candidate_matrix, sorted
canonicalize_combos <- function(df, candidate_matrix, possible_products) {
  solo_counts <- colSums(df[possible_products])
  apply(
    candidate_matrix,
    2,
    \(products) {
      products[product_sort_order(products, solo_counts, possible_products)]
    }
  )
}


# Sort a combo's own products into that canonical order.
sort_products <- function(products, solo_counts, possible_products) {
  products[product_sort_order(products, solo_counts, possible_products)]
}


reach_threshold_at_rank <- function(total_reach, n_return) {
  pos <- length(total_reach) - n_return + 1
  sort(total_reach, partial = pos)[pos]
}
