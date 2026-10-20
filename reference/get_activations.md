# Find the respondents a combination reaches

A respondent is reached by a combination if they are activated by at
least one of its products.

## Usage

``` r
get_activations(mat, cols)
```

## Arguments

- mat:

  A data frame or matrix of activations, with one row per respondent and
  one column per product.

- cols:

  A character vector of products (column names of `mat`).

## Value

A logical vector with one element per row of `mat`: `TRUE` if that
respondent is reached.

## Details

This is a low-level helper and does no input checking: `cols` must be
columns of `mat` containing only `0` and `1`.

## See also

[`marginal_activations()`](https://adam-hubbs.github.io/y2turf/reference/marginal_activations.md)
to count the respondents reached.

## Examples

``` r
reached <- get_activations(am, c("northwind", "may"))
head(reached)
#> [1] FALSE  TRUE FALSE FALSE FALSE FALSE
```
