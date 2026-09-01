# ---------------------------------------------------------------------------
# y2turf benchmarks
#
# Interactive benchmarking of turf() across combinations of num_products,
# batch_size, and use_swaps, timed with bench::mark(). Uses the package's
# built-in `am` activation dataset (15,000 respondents x 53 products).
#
# Not part of automated tests / R CMD check -- run interactively, section by
# section, in the console. Some of the larger/exhaustive configurations below
# are slow (tens of seconds); that's expected and fine to wait out.
# ---------------------------------------------------------------------------

library(devtools)
devtools::load_all()
library(bench)

possible_products <- colnames(am)

# ===========================================================================
# num_products = 4
# ===========================================================================

rst_4 <- bench::mark(
  products4_batch1_noswap = turf(
    am,
    possible_products,
    num_products = 4,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products4_batch1_swap = turf(
    am,
    possible_products,
    num_products = 4,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  products4_batch2_noswap = turf(
    am,
    possible_products,
    num_products = 4,
    batch_size = 2,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products4_batch2_swap = turf(
    am,
    possible_products,
    num_products = 4,
    batch_size = 2,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  products4_full = turf(
    am,
    possible_products,
    num_products = 4,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  check = FALSE,
  iterations = 10
)

# ===========================================================================
# num_products = 8
# ===========================================================================

rst_8 <- bench::mark(
  products8_batch1_noswap = turf(
    am,
    possible_products,
    num_products = 8,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products8_batch1_swap = turf(
    am,
    possible_products,
    num_products = 8,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  products8_batch2_noswap = turf(
    am,
    possible_products,
    num_products = 8,
    batch_size = 2,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products8_batch2_swap = turf(
    am,
    possible_products,
    num_products = 8,
    batch_size = 2,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  products8_batch4_noswap = turf(
    am,
    possible_products,
    num_products = 8,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products8_batch4_swap = turf(
    am,
    possible_products,
    num_products = 8,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  # products8_full = turf(
  #   am,
  #   possible_products,
  #   num_products = 8,
  #   batch_size = 8,
  #   keep_n_at_batch = 15,
  #   num_return = 5,
  #   use_swaps = TRUE,
  #   show_combinations = FALSE
  # ),
  check = FALSE,
  iterations = 1
)

# ===========================================================================
# num_products = 12
# ===========================================================================

rst_12 <- bench::mark(
  products12_batch1_noswap = turf(
    am,
    possible_products,
    num_products = 12,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products12_batch1_swap = turf(
    am,
    possible_products,
    num_products = 12,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  products12_batch2_noswap = turf(
    am,
    possible_products,
    num_products = 12,
    batch_size = 2,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products12_batch2_swap = turf(
    am,
    possible_products,
    num_products = 12,
    batch_size = 2,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  products12_batch4_noswap = turf(
    am,
    possible_products,
    num_products = 12,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = FALSE,
    show_combinations = FALSE
  ),
  products12_batch4_swap = turf(
    am,
    possible_products,
    num_products = 12,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 5,
    use_swaps = TRUE,
    show_combinations = FALSE
  ),
  # products12_full = turf(
  #   am,
  #   possible_products,
  #   num_products = 12,
  #   batch_size = 12,
  #   keep_n_at_batch = 15,
  #   num_return = 5,
  #   use_swaps = TRUE,
  #   show_combinations = FALSE
  # ),
  check = FALSE,
  iterations = 1
)
