validate_turf_args <- function(
  df,
  possible_products,
  num_products,
  batch_size,
  keep_n_at_batch,
  num_return,
  show_combinations,
  use_swaps,
  swap_top_n,
  call = rlang::caller_env()
) {
  rlang::check_required(df, call = call)
  rlang::check_required(possible_products, call = call)
  rlang::check_required(num_products, call = call)
  rlang::check_required(batch_size, call = call)
  rlang::check_required(keep_n_at_batch, call = call)

  rlang::check_data_frame(df, call = call)

  if (!is.character(possible_products) || length(possible_products) == 0) {
    cli::cli_abort(
      "{.arg possible_products} must be a non-empty character vector.",
      call = call
    )
  }
  missing_products <- setdiff(possible_products, colnames(df))
  if (length(missing_products) > 0) {
    cli::cli_abort(
      "{.arg possible_products} must all be columns of {.arg df}: missing {.val {missing_products}}.",
      call = call
    )
  }

  cell_values <- unique(unlist(df[possible_products], use.names = FALSE))
  invalid_values <- setdiff(cell_values, c(0, 1))
  if (length(invalid_values) > 0) {
    cli::cli_abort(
      "{.arg df} columns named in {.arg possible_products} must contain only 0s and 1s, not {.val {invalid_values}}.",
      call = call
    )
  }

  rlang::check_number_whole(num_products, min = 1, call = call)
  rlang::check_number_whole(batch_size, min = 1, call = call)
  rlang::check_number_whole(keep_n_at_batch, min = 1, call = call)
  rlang::check_number_whole(num_return, min = 1, call = call)
  rlang::check_number_whole(swap_top_n, min = 1, call = call)
  rlang::check_bool(show_combinations, call = call)
  rlang::check_bool(use_swaps, call = call)

  if (num_products > length(possible_products)) {
    cli::cli_abort(
      "{.arg num_products} {.val {num_products}} cannot exceed the number of possible products {.val {length(possible_products)}}.",
      call = call
    )
  }

  invisible(NULL)
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
