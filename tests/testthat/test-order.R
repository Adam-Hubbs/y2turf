test_that("order_products orders greedily by marginal reach after the first product", {
  df <- data.frame(
    A = c(1, 1, 1, 1, 0, 0, 0, 0),
    B = c(1, 1, 1, 0, 0, 0, 0, 0),
    C = c(0, 0, 0, 0, 1, 1, 0, 0),
    D = c(0, 0, 0, 0, 0, 1, 1, 1)
  )

  result <- order_products(df, c("A", "B", "C", "D"))

  expect_equal(result$step, 1:4)
  expect_equal(result$product, c("A", "D", "C", "B"))
  expect_equal(result$solo_reach, c(50, 37.5, 25, 37.5))
  expect_equal(result$marginal_reach, c(50, 37.5, 12.5, 0))
  expect_equal(result$total_reach, c(50, 87.5, 100, 100))
  expect_equal(result$frequency, c(50, 87.5, 112.5, 150))
})

test_that("order_products breaks marginal ties by solo reach, then input position", {
  df <- data.frame(
    A = c(1, 0, 0, 0, 0, 0),
    B = c(0, 1, 0, 0, 0, 0),
    C = c(0, 0, 1, 1, 0, 0),
    D = c(0, 0, 0, 0, 1, 0),
    E = c(0, 0, 0, 0, 0, 1)
  )

  expect_equal(
    order_products(df, c("A", "B", "C", "D", "E"))$product,
    c("A", "C", "B", "D", "E")
  )
})

test_that("order_products keeps the first product first and ends at the combination's reach", {
  df <- make_activations(500, 8, seed = 4817)
  products <- c("p03", "p01", "p07", "p05")

  result <- order_products(df, products)

  expect_equal(result$product[1], "p03")
  expect_setequal(result$product, products)
  expect_equal(
    result$total_reach[nrow(result)],
    100 * combo_reach(df, products) / nrow(df)
  )
  expect_equal(
    result$frequency[nrow(result)],
    100 * sum(df[products]) / nrow(df)
  )
  expect_false(is.unsorted(result$total_reach))
  expect_equal(sum(result$marginal_reach), result$total_reach[nrow(result)])
})

test_that("order_products handles a single product", {
  df <- data.frame(A = c(1, 0, 1, 1), B = c(0, 0, 0, 1))

  result <- order_products(df, "A")

  expect_equal(nrow(result), 1)
  expect_equal(result$total_reach, 75)
  expect_equal(result$marginal_reach, 75)
})

test_that("order_products validates its inputs", {
  df <- data.frame(A = c(1, 0), B = c(0, 1))

  expect_error(order_products(df, c("A", "Z")), "missing")
  expect_error(order_products(df, c("A", "A")), "duplicates")
  expect_error(order_products(df, character()), "non-empty")
  expect_error(order_products(df, 1), "character vector")
  expect_error(order_products(data.frame(A = c(1, 2)), "A"), "0s and 1s")
  expect_error(order_products(data.frame(A = c(1, NA)), "A"), "0s and 1s")
  expect_error(order_products(df[0, ], "A"), "at least one row")
})

test_that("extract_combination returns the products at a given rank", {
  df <- make_activations(500, 8, seed = 2093)
  result <- turf(
    df,
    colnames(df),
    num_products = 3,
    batch_size = 3,
    keep_n_at_batch = 10,
    num_return = 3,
    show_combinations = FALSE
  )

  expect_equal(extract_combination(result), result$products[[1]])
  expect_equal(extract_combination(result, rank = 2), result$products[[2]])
  expect_type(extract_combination(result), "character")
})

test_that("extract_combination errors on a bad result or rank", {
  result <- tibble::tibble(
    rank = 1:2,
    products = list(c("A", "B"), c("A", "C"))
  )

  expect_error(extract_combination(result, rank = 3), "not in")
  expect_error(extract_combination(tibble::tibble(x = 1)), "missing column")
  expect_error(extract_combination(list(rank = 1)), "data frame")
})

test_that("order_products works on the output of extract_combination", {
  result <- turf(
    am,
    colnames(am),
    num_products = 4,
    batch_size = 2,
    keep_n_at_batch = 10,
    num_return = 1,
    show_combinations = FALSE
  )

  ordered <- order_products(am, extract_combination(result))

  expect_equal(ordered$product[1], result$products[[1]][1])
  expect_equal(
    ordered$total_reach[4],
    100 * result$total_reach[1] / nrow(am)
  )
})
