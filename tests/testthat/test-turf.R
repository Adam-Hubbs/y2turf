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

test_that("all_candidate_combinations enumerates every combination in combn-style order", {
  combs <- all_candidate_combinations(c("A", "B", "C", "D"), 2)

  expect_equal(dim(combs), c(2L, 6L))
  expect_equal(combs, combn(c("A", "B", "C", "D"), 2))
})

test_that("all_candidate_combinations errors when size exceeds the product universe", {
  expect_snapshot(error = TRUE, all_candidate_combinations(c("A", "B"), 3))
})

test_that("run_batch keeps the top keep_n combinations by marginal reach, ties by input order", {
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

  expect_equal(result$combos, matrix(c("A", "B", "A", "D", "B", "D"), nrow = 2))
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

  winner <- result$products[[1]]
  neighbor_combos <- find_swaps(winner, possible_products)
  neighbor_reach <- apply(neighbor_combos, 2, \(cols) {
    sum(get_activations(am, cols))
  })

  expect_true(all(neighbor_reach <= result$total_reach[1]))
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
  possible_products <- colnames(am)

  # This combination of arguments is known to produce a final batch where
  # swapping (reshuffling between the fixed prefix and the newly-added
  # products) finds a strictly better combination than the raw, unswapped
  # batch result -- regression test for the bug where that swap result was
  # computed but never used.
  result <- turf(
    am,
    possible_products,
    num_products = 9,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 1,
    use_swaps = TRUE,
    show_combinations = FALSE
  )

  expect_equal(result$total_reach, 13169)
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
      num_return = 30,
      show_combinations = FALSE
    )
  })
  expect_equal(nrow(result), 30)
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
      num_return = 50,
      show_combinations = FALSE
    )
  })
  expect_equal(nrow(result), 28)
})
