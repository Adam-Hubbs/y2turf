make_activations <- function(n_respondents, n_products, seed) {
  withr::with_seed(seed, {
    probs <- stats::runif(n_products, 0.05, 0.4)
    cols <- lapply(probs, \(p) stats::rbinom(n_respondents, 1, p))
  })
  names(cols) <- sprintf("p%02d", seq_len(n_products))
  tibble::as_tibble(cols)
}

combo_reach <- function(df, products) {
  sum(rowSums(df[products]) > 0)
}

# Every combination of `size` products, best first.
brute_force_turf <- function(df, size) {
  combos <- utils::combn(colnames(df), size, simplify = FALSE)
  reach <- vapply(combos, \(p) combo_reach(df, p), numeric(1))
  frequency <- vapply(combos, \(p) sum(df[p]), numeric(1))
  ranked <- order(-reach, -frequency)
  tibble::tibble(
    products = combos[ranked],
    total_reach = reach[ranked],
    total_frequency = frequency[ranked]
  )
}

# Every combination reachable from `combo` by replacing one product.
single_swaps <- function(combo, possible_products) {
  others <- setdiff(possible_products, combo)
  unlist(
    lapply(seq_along(combo), \(i) lapply(others, \(p) replace(combo, i, p))),
    recursive = FALSE
  )
}

# Greedy is fooled: A alone reaches most, but B and C together reach everyone.
greedy_trap <- data.frame(
  A = c(1, 1, 1, 1, 1, 1, 0, 0, 0, 0),
  B = c(1, 1, 1, 0, 0, 0, 1, 1, 0, 0),
  C = c(0, 0, 0, 1, 1, 1, 0, 0, 1, 1),
  D = c(1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
)
