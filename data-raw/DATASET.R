# Simulates `am`, the example activation data. Run from the package root to
# rebuild data/am.rda; the seed makes the result reproducible.

set.seed(5531)

products <- c(
  "northwind",
  "southwind",
  "may",
  "flick",
  "toasty",
  "slimey",
  "slim",
  "heavy",
  "blue",
  "red",
  "green",
  "coi",
  "herring",
  "bengal",
  "plum",
  "pair",
  "cherry",
  "lime",
  "apple",
  "mango",
  "peach",
  "tomato",
  "lettuce",
  "zuccini",
  "cucumber",
  "pickle",
  "olive",
  "grape",
  "grapefruit",
  "lemon",
  "citrus",
  "pink",
  "neon",
  "shady",
  "wide",
  "papaya",
  "orange",
  "penne",
  "lasagna",
  "orzo",
  "fluff",
  "hairy",
  "bald",
  "nether",
  "seattle",
  "tokyo",
  "london",
  "madrid",
  "rome",
  "moscow",
  "liverpool",
  "manchester",
  "york"
)

# Each segment has its own activation rate per product, given as runs of
# consecutive products (`sizes`) sharing a rate (`rates`, in percent).
segments <- list(
  list(
    n = 5000,
    sizes = c(4, 5, 5, 5, 4, 3, 2, 3, 3, 3, 4, 5, 4, 3),
    rates = c(25, 22, 20, 15, 11, 7, 6, 9, 8, 7, 6, 5, 4, 3) / 100
  ),
  list(
    n = 4000,
    sizes = c(4, 4, 6, 5, 4, 3, 3, 2, 3, 3, 4, 5, 3, 4),
    rates = c(15, 12, 13, 11, 10, 8, 5, 40, 20, 10, 9, 7, 6, 8) / 100
  ),
  list(
    n = 3000,
    sizes = c(3, 6, 5, 5, 3, 4, 2, 3, 3, 3, 4, 6, 3, 3),
    rates = c(29, 34, 31, 30, 32, 14, 28, 11, 2, 3, 30, 4, 5, 31) / 100
  ),
  list(
    n = 2000,
    sizes = c(4, 5, 5, 5, 3, 4, 2, 3, 2, 4, 3, 6, 4, 3),
    rates = c(13, 17, 24, 18, 11, 12, 18, 22, 20, 10, 21, 23, 40, 28) / 100
  ),
  list(
    n = 1000,
    sizes = c(4, 5, 5, 6, 3, 3, 3, 3, 2, 4, 3, 5, 4, 3),
    rates = c(15, 10, 27, 10, 8, 7, 6, 20, 16, 11, 14, 50, 17, 21) / 100
  )
)

simulate_segment <- function(segment) {
  p <- rep(segment$rates, segment$sizes)
  stopifnot(length(p) == length(products))
  n <- segment$n
  matrix(stats::rbinom(n * length(p), 1, rep(p, each = n)), nrow = n)
}

# Sets each cell in `cols` to `value` with probability `p`.
add_noise <- function(m, cols, value, p = 0.1) {
  block <- m[, cols]
  block[stats::runif(length(block)) < p] <- value
  m[, cols] <- block
  m
}

# Keeps a random `max_n` of the activations of any respondent with more.
cap_activations <- function(m, max_n) {
  for (i in which(rowSums(m) > max_n)) {
    ones <- which(m[i, ] == 1L)
    m[i, ] <- 0L
    m[i, sample(ones, max_n)] <- 1L
  }
  m
}

no_dropouts <- c(
  2,
  7,
  12,
  15,
  16,
  20,
  22,
  24,
  28,
  32,
  33,
  35,
  38,
  39,
  41,
  42,
  46,
  48,
  50,
  52
)
no_additions <- c(1, 4, 5, 7, 8, 13, 14, 17, 22, 26, 28, 29, 31, 36, 41, 43, 50)

am <- do.call(rbind, lapply(segments, simulate_segment))
colnames(am) <- products
am <- am |>
  add_noise(setdiff(seq_along(products), no_dropouts), 0L) |>
  add_noise(setdiff(seq_along(products), no_additions), 1L) |>
  cap_activations(5) |>
  tibble::as_tibble()

# Activations per respondent
tibble::tibble(total = rowSums(am)) |>
  y2clerk::freqs(total)

# Respondents activated by each product
am |>
  y2clerk::freqs(tidyselect::everything()) |>
  dplyr::filter(value == 1) |>
  dplyr::arrange(dplyr::desc(n))

usethis::use_data(am, overwrite = TRUE)
