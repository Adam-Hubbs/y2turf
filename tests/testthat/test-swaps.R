test_that("find_swaps enumerates every one-product swap for each position", {
  swaps <- find_swaps(c("A", "B"), c("A", "B", "C", "D"))

  expect_equal(dim(swaps), c(2L, 4L))
  expect_equal(
    swaps,
    matrix(c("C", "B", "D", "B", "A", "C", "A", "D"), nrow = 2)
  )
})

test_that("find_swaps returns no columns when there are no other products to swap in", {
  swaps <- find_swaps(c("A", "B"), c("A", "B"))
  expect_equal(dim(swaps), c(2L, 0L))
})

test_that("do_swaps de-duplicates repeated candidate columns", {
  df <- data.frame(
    A = c(1, 0, 0, 0, 1, 0),
    B = c(0, 1, 0, 0, 0, 1),
    C = c(0, 0, 1, 0, 0, 0),
    D = c(0, 0, 0, 1, 1, 1)
  )
  product_order <- determine_product_order(df, c("A", "B", "C", "D"))

  swaps <- do_swaps(matrix(c("A", "B"), ncol = 1), c("A", "B", "C", "D"), product_order)

  expect_equal(ncol(swaps), 4)
  expect_equal(anyDuplicated(t(swaps)), 0)
})

test_that("combo_set_unchanged compares column sets, ignoring column order", {
  x <- matrix(c("A", "B", "C", "D"), nrow = 2) # columns: AB, CD
  y <- matrix(c("C", "D", "A", "B"), nrow = 2) # same set, columns reordered
  z <- matrix(c("A", "B", "A", "C"), nrow = 2) # different set: AB, AC

  expect_true(combo_set_unchanged(x, y))
  expect_false(combo_set_unchanged(x, z))
})

test_that("top_n_combinations keeps the top-scoring columns by full reach", {
  df <- data.frame(
    A = c(1, 0, 0, 0, 1, 0),
    B = c(0, 1, 0, 0, 0, 1),
    C = c(0, 0, 1, 0, 0, 0),
    D = c(0, 0, 0, 1, 1, 1)
  )
  combs <- all_candidate_combinations(c("A", "B", "C", "D"), 2)

  result <- top_n_combinations(df, combs, top_n = 2)

  expect_equal(result$combos, matrix(c("A", "B", "A", "D"), nrow = 2))
  expect_equal(result$total_reach, c(4, 4))
})

test_that("swap_until_stable skips swapping when the combination already uses every possible product", {
  df <- data.frame(
    A = c(1, 0, 0, 0, 1, 0),
    B = c(0, 1, 0, 0, 0, 1)
  )
  product_order <- determine_product_order(df, c("A", "B"))

  result <- swap_until_stable(
    df,
    matrix(c("A", "B"), ncol = 1),
    fixed = character(0),
    possible_products = c("A", "B"),
    product_order = product_order,
    top_n = 1,
    starting_n = 1
  )

  expect_equal(result$n_combinations, 0)
  expect_equal(sort(result$combos[, 1]), c("A", "B"))
})

test_that("swap_until_stable warns and returns its best-so-far result if it doesn't converge", {
  df <- data.frame(
    A = c(1, 0, 0, 0, 1, 0),
    B = c(0, 1, 0, 0, 0, 1),
    C = c(0, 0, 1, 0, 0, 0),
    D = c(0, 0, 0, 1, 1, 1)
  )
  product_order <- determine_product_order(df, c("A", "B", "C", "D"))

  expect_snapshot({
    result <- swap_until_stable(
      df,
      matrix(c("C", "D"), ncol = 1),
      fixed = character(0),
      possible_products = c("A", "B", "C", "D"),
      product_order = product_order,
      top_n = 2,
      starting_n = 2,
      max_rounds = 0
    )
  })
  expect_equal(result$total_reach, 4)
})
