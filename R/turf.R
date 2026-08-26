#' Run a TURF analysis
#'
#' Runs a TURF analysis with an efficient algorithm that only checks combinations that are plausibly correct.
#'
#' @param df The activation dataframe. Columns must be the names of possible products. Rows indicate individual respondents. For now each cell must be either a 0 or a 1.
#' @param possible_products The universe of possible products we are testing. Given as a character vector.
#' @param num_products The number of products to be included in our competetive set. A positive integer.
#' @param batch_size The number of products to solve for at a given time. A positive integer. Note: We may override this in order to make sure we hit num_return.
#' @param keep_n_at_batch The number of solutions from each batch that we do the swapping step on. A positive integer.
#' @param num_return The n-best solutions to return from turf(). A positive integer.
#' @param show_combinations Whether to show the number of combinations searched or not. A boolean.
#' @param use_swaps Whether to augment the main algorithm with swapping after each batch_size. A boolean.
#' @param swap_top_n The number of combinations the swap algorithm continues each step on until they no longer change. A positive integer.
#'
#' @return A dataframe with the combinations and corresponding reach
#' @export
turf <- function(
  df,
  possible_products,
  num_products,
  batch_size,
  keep_n_at_batch,
  num_return = 1,
  show_combinations = TRUE,
  use_swaps = TRUE,
  swap_top_n = 3
) {
  validate_turf_args(
    df,
    possible_products,
    num_products,
    batch_size,
    keep_n_at_batch,
    num_return,
    show_combinations,
    use_swaps,
    swap_top_n
  )

  product_order <- determine_product_order(df, possible_products)

  batch_sizes <- determine_batch_sizes(
    length(possible_products),
    num_products,
    batch_size,
    num_return
  )
  warn_if_batches_combined(batch_sizes, batch_size, num_products, num_return)

  fixed <- character(0)
  fixed_before_final_batch <- character(0)
  final_batch_result <- NULL
  final_swap_result <- NULL
  regular_combinations_searched <- 0
  swap_combinations_searched <- 0

  for (i in seq_along(batch_sizes)) {
    size <- batch_sizes[i]
    is_final_batch <- i == length(batch_sizes)
    keep_n_at_this_batch <- if (is_final_batch) {
      max(keep_n_at_batch, num_return)
    } else {
      keep_n_at_batch
    }
    final_batch_result <- run_batch(
      df,
      possible_products,
      size,
      fixed = if (length(fixed) == 0) NA else fixed,
      keep_n = keep_n_at_this_batch
    )
    regular_combinations_searched <- regular_combinations_searched +
      final_batch_result$n_combinations

    fixed_before_final_batch <- fixed
    final_swap_result <- NULL

    if (use_swaps && i > 1) {
      # On the final batch, the swap step's own result *is* the output --
      # not just a seed for the next batch -- so widen its `top_n` to cover
      # `num_return` distinct combinations rather than just `swap_top_n`.
      swap_result <- swap_until_stable(
        df,
        final_batch_result$combos,
        fixed,
        possible_products,
        product_order,
        top_n = if (is_final_batch) max(swap_top_n, num_return) else swap_top_n,
        starting_n = keep_n_at_this_batch
      )
      swap_combinations_searched <- swap_combinations_searched +
        swap_result$n_combinations

      if (is_final_batch) {
        final_swap_result <- swap_result
      } else {
        fixed <- swap_result$combos[, 1]
      }
    } else {
      fixed <- c(fixed, final_batch_result$combos[, 1])
    }
  }

  warn_if_insufficient_combos(
    if (is.null(final_swap_result)) {
      ncol(final_batch_result$combos)
    } else {
      ncol(final_swap_result$combos)
    },
    num_return
  )

  result <- if (is.null(final_swap_result)) {
    collect_top_combos(
      df,
      fixed_before_final_batch,
      final_batch_result,
      num_return,
      product_order
    )
  } else {
    combos_list <- purrr::map(
      seq_len(ncol(final_swap_result$combos)),
      \(i) final_swap_result$combos[, i]
    )
    rank_combos(df, combos_list, num_return, product_order)
  }

  if (show_combinations) {
    total_combinations_searched <- regular_combinations_searched +
      swap_combinations_searched
    cli::cli_inform(
      "Searched {total_combinations_searched} combination{?s}: {regular_combinations_searched} regular combination{?s} and {swap_combinations_searched} swap combination{?s} across {length(batch_sizes)} batch{?es}."
    )
    attr(result, "n_combinations") <- total_combinations_searched
    attr(result, "n_regular_combinations") <- regular_combinations_searched
    attr(result, "n_swap_combinations") <- swap_combinations_searched
  }

  result
}

#' Run a the turf algorithm for a batch
#'
#' @inheritParams turf df possible_products
#' @param size The size of the batch (Number of additional products to determine order for)
#' @param fixed A character vecor of products who have already been found in a previous batch
#' @param keep_n The number of top combinations to do swaps on.
#'
#' @return A list with a matrix where each column contains a combination, and an integer vector of reach for each combination.
#'
#' @export
run_batch <- function(df, possible_products, size, fixed = NA, keep_n = 20) {
  batch_products <- setdiff(possible_products, fixed)
  combs <- all_candidate_combinations(batch_products, size)

  # Respondents already reached by `fixed` can't contribute any marginal
  # reach, so drop them before scoring candidates
  has_fixed <- length(fixed) > 0 && !(length(fixed) == 1 && is.na(fixed))
  slim_df <- if (has_fixed) {
    df[get_activations(df, fixed) == 0, , drop = FALSE]
  } else {
    df
  }

  # Proof of concept: score every combination one at a time. Fine for now;
  # revisit (vectorize/chunk, or rewrite in C++/Rust) once this needs to run
  # at real scale.
  reach <- apply(combs, 2, \(cols) {
    marginal_activations(get_activations(slim_df, cols))
  })

  # This is not tie-stable. Need to seperate it out into just order. Then split to see if there is a tie. If there is, run get_activations on all to find frequency.
  keep <- order(reach, decreasing = TRUE)[seq_len(min(keep_n, length(reach)))]
  # Note that this returns marginal reach not full reach. `n_combinations` is
  # the count *before* trimming to `keep_n` -- i.e. how many candidates this
  # batch actually searched -- and is essentially free since `combs` already
  # exists; `turf()` sums this across batches and only surfaces it when
  # `show_combinations = TRUE`.
  list(
    combos = combs[, keep, drop = FALSE],
    reach = reach[keep],
    n_combinations = ncol(combs)
  )
}

all_candidate_combinations <- function(possible_products, size) {
  n <- length(possible_products)
  if (size > n) {
    cli::cli_abort(
      "{.arg size} {.val {size}} cannot exceed the number of possible products {.val {n}}."
    )
  }

  n_combos <- choose(n, size)
  if (n_combos > 2e8) {
    cli::cli_warn(
      "Requested {.val {n_combos}} combinations (n = {n}, size = {size}); this may exhaust memory/time."
    )
  }

  rows <- vector("list", size)
  rows[[1]] <- seq_len(n)
  if (size > 1) {
    for (step in 2:size) {
      last <- rows[[step - 1]]
      remaining <- n - last
      for (r in seq_len(step - 1)) {
        rows[[r]] <- rep.int(rows[[r]], remaining)
      }
      rows[[step]] <- sequence(remaining) + rep.int(last, remaining)
    }
  }

  idx <- do.call(rbind, rows)
  matrix(possible_products[idx], nrow = size)
}

prepare_full_candidates <- function(all_candidates, fixed) {
  n_combos <- ncol(all_candidates)
  fixed_mat <- matrix(fixed, nrow = length(fixed), ncol = n_combos)
  rbind(fixed_mat, all_candidates)
}


# Work out how many products each batch should add.
#
# The final batch's feasibility (whether it can produce at least
# `num_return` distinct combinations) only depends on how many products are
# fixed before it -- not on which earlier batches contributed them. So
# instead of checking one batch ahead at a time (which can't see past a
# single merge) or discovering a shortfall after committing batches and
# rolling back, we solve for the whole schedule once, upfront: search over
# how many trailing default-sized batches (`k`) need to be folded into the
# final one, then return the full vector of batch sizes (e.g.
# `c(1, 1, 1, 1, 1, 1, 2)`), always summing to `num_products`.
determine_batch_sizes <- function(
  n_possible,
  num_products,
  batch_size,
  num_return
) {
  default_final_size <- num_products -
    batch_size * ((num_products - 1) %/% batch_size)
  k_max <- (num_products - default_final_size) %/% batch_size

  final_size <- num_products # fallback: fold every batch into one
  for (k in 0:k_max) {
    candidate <- default_final_size + k * batch_size
    n_fixed_before_final <- num_products - candidate
    if (choose(n_possible - n_fixed_before_final, candidate) >= num_return) {
      final_size <- candidate
      break
    }
  }

  n_prior_batches <- (num_products - final_size) %/% batch_size
  c(rep(batch_size, n_prior_batches), final_size)
}
