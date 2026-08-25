test_that("margional_activations() returns the sum of the vector", {
  vec <- c(1, 5, 1, 4, 3, 2)

  expect_equal(16, marginal_activations(vec))
})
