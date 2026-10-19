test_that("determine_batch_sizes uses one batch per product when num_return is easily reached", {
  expect_equal(
    determine_batch_sizes(
      n_possible = 6,
      num_products = 4,
      batch_size = 1,
      num_return = 2
    ),
    c(1, 1, 1, 1)
  )
})

test_that("determine_batch_sizes grows the final batch to guarantee num_return distinct combinations", {
  batch_sizes <- determine_batch_sizes(
    n_possible = 5,
    num_products = 4,
    batch_size = 1,
    num_return = 3
  )

  expect_equal(batch_sizes, c(1, 1, 2))
  expect_equal(sum(batch_sizes), 4)
})

test_that("run_batch errors when size exceeds the remaining products", {
  df <- data.frame(A = c(1, 0), B = c(0, 1), C = c(1, 1))

  expect_snapshot(
    error = TRUE,
    run_batch(df, c("A", "B", "C"), size = 3, fixed = "A")
  )
})

test_that("run_batch keeps the top keep_n combinations by marginal reach, then frequency, then input order", {
  df <- data.frame(
    A = c(1, 0, 0, 0, 1, 0),
    B = c(0, 1, 0, 0, 0, 1),
    C = c(0, 0, 1, 0, 0, 0),
    D = c(0, 0, 0, 1, 1, 1)
  )

  result <- run_batch(
    df,
    c("A", "B", "C", "D"),
    size = 2,
    fixed = NA,
    keep_n = 3
  )

  expect_equal(result$combos, matrix(c("A", "D", "B", "D", "A", "B"), nrow = 2))
  expect_equal(result$reach, c(4, 4, 4))
  expect_equal(result$n_combinations, 6)
})

test_that("turf() returns a correctly-ordered, correctly-shaped result for a real activation dataset", {
  possible_products <- colnames(am)

  result <- turf(
    am,
    possible_products,
    num_products = 3,
    batch_size = 1,
    keep_n_at_batch = 10,
    num_return = 3,
    use_swaps = TRUE,
    show_combinations = FALSE
  )

  expect_equal(result$rank, 1:3)
  expect_true(all(diff(result$total_reach) <= 0))
  expect_true(all(lengths(result$products) == 3))
  expect_snapshot(result)
})

test_that("turf() with swaps finds a locally stable combination (no single swap improves reach)", {
  possible_products <- colnames(am)

  result <- turf(
    am,
    possible_products,
    num_products = 4,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 1,
    use_swaps = TRUE,
    show_combinations = FALSE
  )

  neighbors <- single_swaps(result$products[[1]], possible_products)
  neighbor_reach <- vapply(neighbors, \(p) combo_reach(am, p), numeric(1))
  expect_lte(max(neighbor_reach), result$total_reach[1])
})

test_that("turf() aborts when a required argument is missing or malformed", {
  possible_products <- colnames(am)

  expect_snapshot(error = TRUE, turf())
  expect_snapshot(
    error = TRUE,
    turf(
      list(A = 1),
      "A",
      num_products = 1,
      batch_size = 1,
      keep_n_at_batch = 1
    )
  )
  expect_snapshot(
    error = TRUE,
    turf(
      am,
      possible_products,
      num_products = "3",
      batch_size = 1,
      keep_n_at_batch = 10
    )
  )
  expect_snapshot(
    error = TRUE,
    turf(
      am,
      possible_products,
      num_products = 3,
      batch_size = 1,
      keep_n_at_batch = 10,
      show_combinations = "yes"
    )
  )
})

test_that("turf() aborts when df contains values other than 0 and 1", {
  df <- data.frame(A = c(1, 0, 2), B = c(0, 1, 0))

  expect_snapshot(
    error = TRUE,
    turf(df, c("A", "B"), num_products = 1, batch_size = 1, keep_n_at_batch = 1)
  )
})

test_that("turf() aborts when df contains missing values", {
  df <- data.frame(A = c(1, 0, NA), B = c(0, 1, 0))

  expect_snapshot(
    error = TRUE,
    turf(df, c("A", "B"), num_products = 1, batch_size = 1, keep_n_at_batch = 1)
  )
})

test_that("turf() applies the final batch's swap refinement instead of discarding it", {
  # These arguments are known to produce a final batch where swapping finds a
  # strictly better combination than the unswapped batch result.
  run <- \(use_swaps) {
    turf(
      am,
      colnames(am),
      num_products = 9,
      batch_size = 4,
      keep_n_at_batch = 15,
      use_swaps = use_swaps,
      show_combinations = FALSE
    )
  }

  expect_equal(run(use_swaps = FALSE)$total_reach, 11389)
  expect_equal(run(use_swaps = TRUE)$total_reach, 11391)
})

test_that("turf() aborts when possible_products is invalid", {
  possible_products <- colnames(am)

  expect_snapshot(
    error = TRUE,
    turf(am, 1:5, num_products = 3, batch_size = 1, keep_n_at_batch = 10)
  )
  expect_snapshot(
    error = TRUE,
    turf(
      am,
      c(possible_products, "nope"),
      num_products = 3,
      batch_size = 1,
      keep_n_at_batch = 10
    )
  )
})

test_that("turf() aborts when num_products exceeds the product universe", {
  possible_products <- colnames(am)

  expect_snapshot(
    error = TRUE,
    turf(
      am,
      possible_products,
      num_products = 100,
      batch_size = 1,
      keep_n_at_batch = 10
    )
  )
})

test_that("turf() no longer requires num_return <= keep_n_at_batch", {
  possible_products <- colnames(am)

  result <- turf(
    am,
    possible_products,
    num_products = 3,
    batch_size = 1,
    keep_n_at_batch = 2,
    num_return = 5,
    show_combinations = FALSE
  )

  expect_equal(nrow(result), 5)
})

test_that("turf() warns when the final batch must be combined with earlier batches", {
  possible_products <- colnames(am)

  expect_snapshot({
    result <- turf(
      am,
      possible_products,
      num_products = 5,
      batch_size = 2,
      keep_n_at_batch = 50,
      num_return = 60,
      show_combinations = FALSE
    )
  })
  expect_equal(nrow(result), 60)
})

test_that("turf() warns when fewer combinations exist than num_return", {
  possible_products <- colnames(am)

  expect_snapshot({
    result <- turf(
      am,
      possible_products,
      num_products = 1,
      batch_size = 1,
      keep_n_at_batch = 50,
      num_return = 60,
      show_combinations = FALSE
    )
  })
  expect_equal(nrow(result), 53)
})

test_that("turf() returns one ranked row per distinct combination", {
  df <- make_activations(300, 10, seed = 6120)

  result <- turf(
    df,
    colnames(df),
    num_products = 3,
    batch_size = 1,
    keep_n_at_batch = 10,
    num_return = 4,
    show_combinations = FALSE
  )

  expect_named(result, c("rank", "products", "total_reach", "total_frequency"))
  expect_equal(result$rank, 1:4)
  expect_equal(lengths(lapply(result$products, unique)), rep(3, 4))
  expect_in(unlist(result$products), colnames(df))
  expect_equal(anyDuplicated(lapply(result$products, sort)), 0)
  expect_equal(order(-result$total_reach, -result$total_frequency), 1:4)
})

test_that("turf() reports reach and frequency that match its products", {
  df <- make_activations(300, 10, seed = 6120)

  result <- turf(
    df,
    colnames(df),
    num_products = 4,
    batch_size = 2,
    keep_n_at_batch = 10,
    num_return = 5,
    show_combinations = FALSE
  )

  expect_equal(
    result$total_reach,
    vapply(result$products, \(p) combo_reach(df, p), numeric(1))
  )
  expect_equal(
    result$total_frequency,
    vapply(result$products, \(p) sum(df[p]), numeric(1))
  )
})

test_that("turf() lists each combination's products by descending solo reach", {
  df <- make_activations(300, 10, seed = 6120)
  solo <- colSums(df)

  result <- turf(
    df,
    colnames(df),
    num_products = 4,
    batch_size = 2,
    keep_n_at_batch = 10,
    num_return = 5,
    show_combinations = FALSE
  )

  for (p in result$products) {
    expect_equal(p, p[order(-solo[p], match(p, colnames(df)))])
  }
})

test_that("turf() with a single batch matches brute force", {
  df <- make_activations(200, 8, seed = 2817)

  for (k in 1:4) {
    result <- turf(
      df,
      colnames(df),
      num_products = k,
      batch_size = k,
      keep_n_at_batch = 5,
      num_return = 5,
      show_combinations = FALSE
    )
    expected <- brute_force_turf(df, k)[1:5, ]

    expect_equal(result$total_reach, expected$total_reach)
    expect_equal(result$total_frequency, expected$total_frequency)
  }
})

test_that("turf() without swaps follows the greedy path", {
  result <- turf(
    greedy_trap,
    colnames(greedy_trap),
    num_products = 2,
    batch_size = 1,
    keep_n_at_batch = 3,
    use_swaps = FALSE,
    show_combinations = FALSE
  )

  expect_equal(result$products[[1]][1], "A")
  expect_equal(result$total_reach, 8)
})

test_that("turf() with swaps escapes a greedy trap", {
  result <- turf(
    greedy_trap,
    colnames(greedy_trap),
    num_products = 2,
    batch_size = 1,
    keep_n_at_batch = 3,
    use_swaps = TRUE,
    show_combinations = FALSE
  )

  expect_equal(result$products[[1]], c("B", "C"))
  expect_equal(result$total_reach, 10)
})

test_that("turf() with swaps returns a combination no single swap improves", {
  df <- make_activations(400, 12, seed = 4471)

  result <- turf(
    df,
    colnames(df),
    num_products = 4,
    batch_size = 1,
    keep_n_at_batch = 5,
    show_combinations = FALSE
  )

  neighbors <- single_swaps(result$products[[1]], colnames(df))
  neighbor_reach <- vapply(neighbors, \(p) combo_reach(df, p), numeric(1))
  expect_lte(max(neighbor_reach), result$total_reach[1])
})

test_that("turf() reports how many combinations it searched", {
  df <- make_activations(100, 8, seed = 915)
  args <- list(
    df,
    colnames(df),
    num_products = 3,
    batch_size = 3,
    keep_n_at_batch = 5
  )

  expect_message(
    result <- do.call(turf, args),
    "Searched 56 combinations"
  )
  expect_equal(attr(result, "n_combinations"), 56)
  expect_equal(attr(result, "n_regular_combinations"), 56)
  expect_equal(attr(result, "n_swap_combinations"), 0)

  expect_no_message(
    result <- do.call(turf, c(args, show_combinations = FALSE))
  )
  expect_null(attr(result, "n_combinations"))
})

test_that("turf() ignores columns outside possible_products", {
  df <- make_activations(100, 6, seed = 3308)
  with_id <- tibble::add_column(df, id = paste0("r", seq_len(100)), .before = 1)
  run <- \(data) {
    turf(
      data,
      colnames(df),
      num_products = 3,
      batch_size = 1,
      keep_n_at_batch = 5,
      num_return = 3,
      show_combinations = FALSE
    )
  }

  expect_equal(run(with_id), run(df))
})
