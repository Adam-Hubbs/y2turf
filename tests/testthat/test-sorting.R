test_that("determine_product_order ranks by descending solo reach, ties broken by input order", {
  df <- data.frame(
    A = c(1, 1, 0, 0),
    B = c(1, 1, 0, 0),
    C = c(1, 0, 0, 0),
    D = c(1, 1, 1, 0)
  )

  expect_equal(
    determine_product_order(df, c("A", "B", "C", "D")),
    c("D", "A", "B", "C")
  )
})

test_that("sort_products orders products to match the canonical product order", {
  product_order <- c("D", "A", "B", "C")

  expect_equal(sort_products(c("A", "D", "C"), product_order), c("D", "A", "C"))
  expect_equal(sort_products(c("B", "A"), product_order), c("A", "B"))
})
