#' Example activation data
#'
#' Simulated TURF activation data for 15,000 respondents and 53 products. A
#' cell is `1` if the respondent is activated by (would choose) that product,
#' and `0` otherwise.
#'
#' Respondents come from five simulated segments of 5,000, 4,000, 3,000, 2,000,
#' and 1,000 respondents, each with its own activation rate per product, plus
#' some random noise. Overall rates range from about 4% to 14% per product.
#' Every respondent activates on between one and five products; about 98% on
#' exactly five. Product names are arbitrary placeholders.
#'
#' @format A tibble with 15,000 rows (respondents) and 53 columns (products,
#'   `northwind` through `york`). Every column is an integer vector of `0`s and
#'   `1`s.
#' @source Simulated by `data-raw/DATASET.R` in the package source, which
#'   regenerates it exactly.
#' @examples
#' dim(am)
#'
#' # Share of respondents activated by each product
#' head(sort(colMeans(am), decreasing = TRUE))
"am"
