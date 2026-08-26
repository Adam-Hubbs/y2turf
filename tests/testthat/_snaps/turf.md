# all_candidate_combinations errors when size exceeds the product universe

    Code
      all_candidate_combinations(c("A", "B"), 3)
    Condition
      Error in `all_candidate_combinations()`:
      ! `size` 3 cannot exceed the number of possible products 2.

# turf() returns a correctly-ordered, correctly-shaped result for a real activation dataset

    Code
      result
    Output
      # A tibble: 3 x 3
         rank products  total_reach
        <int> <list>          <int>
      1     1 <chr [3]>        6951
      2     2 <chr [3]>        6929
      3     3 <chr [3]>        6923

# turf() aborts when a required argument is missing or malformed

    Code
      turf()
    Condition
      Error in `turf()`:
      ! `df` is absent but must be supplied.

---

    Code
      turf(list(A = 1), "A", num_products = 1, batch_size = 1, keep_n_at_batch = 1)
    Condition
      Error in `turf()`:
      ! `df` must be a data frame, not a list.

---

    Code
      turf(am, possible_products, num_products = "3", batch_size = 1,
        keep_n_at_batch = 10)
    Condition
      Error in `turf()`:
      ! `num_products` must be a whole number, not the string "3".

---

    Code
      turf(am, possible_products, num_products = 3, batch_size = 1, keep_n_at_batch = 10,
        show_combinations = "yes")
    Condition
      Error in `turf()`:
      ! `show_combinations` must be `TRUE` or `FALSE`, not the string "yes".

# turf() aborts when df contains values other than 0 and 1

    Code
      turf(df, c("A", "B"), num_products = 1, batch_size = 1, keep_n_at_batch = 1)
    Condition
      Error in `turf()`:
      ! `df` columns named in `possible_products` must contain only 0s and 1s, not 2.

# turf() aborts when df contains missing values

    Code
      turf(df, c("A", "B"), num_products = 1, batch_size = 1, keep_n_at_batch = 1)
    Condition
      Error in `turf()`:
      ! `df` columns named in `possible_products` must contain only 0s and 1s, not NA.

# turf() aborts when possible_products is invalid

    Code
      turf(am, 1:5, num_products = 3, batch_size = 1, keep_n_at_batch = 10)
    Condition
      Error in `turf()`:
      ! `possible_products` must be a non-empty character vector.

---

    Code
      turf(am, c(possible_products, "nope"), num_products = 3, batch_size = 1,
      keep_n_at_batch = 10)
    Condition
      Error in `turf()`:
      ! `possible_products` must all be columns of `df`: missing "nope".

# turf() aborts when num_products exceeds the product universe

    Code
      turf(am, possible_products, num_products = 100, batch_size = 1,
        keep_n_at_batch = 10)
    Condition
      Error in `turf()`:
      ! `num_products` 100 cannot exceed the number of possible products 28.

# turf() warns when the final batch must be combined with earlier batches

    Code
      result <- turf(am, possible_products, num_products = 5, batch_size = 2,
        keep_n_at_batch = 50, num_return = 30, show_combinations = FALSE)
    Condition
      Warning:
      The final batch was combined with 1 prior batch, growing it from 2 to 3 products, to generate at least 30 distinct results.

# turf() warns when fewer combinations exist than num_return

    Code
      result <- turf(am, possible_products, num_products = 1, batch_size = 1,
        keep_n_at_batch = 50, num_return = 50, show_combinations = FALSE)
    Condition
      Warning:
      Only 28 distinct combinations exist for the final batch.
      i Returning all of them instead of the requested `num_return` = 50.

