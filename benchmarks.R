dta <- am
am_matrix <- dta |>
  dplyr::mutate(across(everything(), \(x) as.integer(x))) |>
  as.matrix()

combos_check <- make_col_combinations(ncol(am_matrix), 25, seed = 6653)

many_cols <- make_col_combinations(ncol(am_matrix), 20000L, seed = 6653)

# row_any_sum_matrix is the rust implementation currently in roxtest
rst_combos <- bench::press(
  .grid = tibble::tibble(n_combos = c(100L, 1000L, 10000L, 100000L)),
  {
    combos <- make_col_combinations(ncol(am_matrix), n_combos, seed = 6653)

    bench::mark(
      apply_get_activations(am_matrix, combos),
      #row_any_sum_matrix(am_matrix, combos),
      check = TRUE,
      iterations = 1
    )
  }
)
