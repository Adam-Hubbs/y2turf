# swap_until_stable warns and returns its best-so-far result if it doesn't converge

    Code
      result <- swap_until_stable(df, matrix(c("C", "D"), ncol = 1), fixed = character(
        0), possible_products = c("A", "B", "C", "D"), product_order = product_order,
      top_n = 2, starting_n = 2, max_rounds = 0)
    Condition
      Warning:
      Swap search did not converge after 0 rounds; returning the best combinations found so far.

