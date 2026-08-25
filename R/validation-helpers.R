validate_turf_args <- function(
  possible_products,
  num_products,
  keep_n_at_batch,
  num_return
) {
  if (num_products > length(possible_products)) {
    cli::cli_abort(
      "{.arg num_products} {.val {num_products}} cannot exceed the number of possible products {.val {length(possible_products)}}."
    )
  }
  if (num_return > keep_n_at_batch) {
    cli::cli_abort(
      "{.arg num_return} {.val {num_return}} cannot exceed {.arg keep_n_at_batch} {.val {keep_n_at_batch}}."
    )
  }
}

warn_if_batches_combined <- function(
  batch_sizes,
  batch_size,
  num_products,
  num_return
) {
  n_expected_batches <- ceiling(num_products / batch_size)
  n_combined <- n_expected_batches - length(batch_sizes)
  final_size <- batch_sizes[length(batch_sizes)]

  if (n_combined > 0) {
    cli::cli_warn(c(
      "The final batch was combined with {n_combined} prior batch{?es}, growing it from {batch_size} to {final_size} product{?s}, to generate at least {num_return} distinct result{?s}."
    ))
  }
}

warn_if_insufficient_combos <- function(n_available, num_return) {
  if (n_available < num_return) {
    cli::cli_warn(c(
      "Only {n_available} distinct combination{?s} exist for the final batch.",
      "i" = "Returning all of them instead of the requested {.arg num_return} = {num_return}."
    ))
  }
}
