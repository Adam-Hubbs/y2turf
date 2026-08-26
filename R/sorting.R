#' Determine canonical product ordering
#'
#' Computes the order products should be sorted in: descending individual
#' (solo) reach, ties broken by the order they appear in `possible_products`.
#' Compute this once per [turf()] call and pass the result to every function
#' that needs to sort a combination's products, rather than recomputing solo
#' reach counts (which require a full pass over `df`) on every call.
#'
#' @inheritParams turf df possible_products
#'
#' @return `possible_products`, reordered into canonical sort order.
determine_product_order <- function(df, possible_products) {
  solo_counts <- colSums(df[possible_products])
  possible_products[order(-solo_counts, seq_along(possible_products))]
}

#' Sort the resut from turf
#'
#' Sorts the result on both dimensions. Sorts products by reach (ties are broken by frequency, then initial position)
#' Sorts rows by total reach, then by frequency
#'
#' Returns the sorted result matrix
#' @inheritParams turf df num_return
#' @param fixed_before_final_batch The combination that was fixed before the final batch. Used for optimizing the sorting since we know this is in a good order already.
#' @param final_batch_result A vector of the activations for the combinations that were fixed before the final batch.
#' @param product_order The canonical product ordering from [determine_product_order()].
#'
#' @return The sorted result of turf()
collect_top_combos <- function(
  df,
  fixed_before_final_batch,
  final_batch_result,
  num_return,
  product_order
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

  rank_combos(df, combos_list, num_return, product_order)
}

#' Score, rank, and format a list of complete product combinations
#'
#' Shared by the marginal-reach shortcut in [collect_top_combos()] and by
#' [turf()]'s handling of an already-swapped final batch, both of which
#' arrive at a list of complete (not just marginal) candidate combinations
#' that need to be scored, ranked, and formatted the same way.
#'
#' @inheritParams turf df num_return
#' @param combos_list A list of character vectors, each a complete product combination.
#' @param product_order The canonical product ordering from [determine_product_order()].
#'
#' @return The sorted result of turf()
rank_combos <- function(df, combos_list, num_return, product_order) {
  n_return <- min(num_return, length(combos_list))

  total_reach <- purrr::map_int(
    combos_list,
    \(products) sum(get_activations(df, products))
  )
  frequency <- purrr::map_dbl(
    combos_list,
    \(products) combo_frequency(df, products)
  )

  ranked <- order(-total_reach, -frequency)[seq_len(n_return)]

  purrr::map(seq_along(ranked), \(rank) {
    idx <- ranked[rank]
    tibble::tibble(
      rank = rank,
      products = list(sort_products(combos_list[[idx]], product_order)),
      total_reach = total_reach[idx]
    )
  }) |>
    purrr::list_rbind()
}

#' Sort a combo's own products into canonical order
#'
#' @param products A character vector of products to sort
#' @param product_order The canonical product ordering from [determine_product_order()].
#'
#' @return `products`, reordered to match `product_order`.
sort_products <- function(products, product_order) {
  products[order(match(products, product_order))]
}


reach_threshold_at_rank <- function(total_reach, n_return) {
  pos <- length(total_reach) - n_return + 1
  sort(total_reach, partial = pos)[pos]
}
