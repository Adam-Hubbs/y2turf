# Count a combination's total activations

Frequency is the total number of activations across a combination's
products. Unlike reach, a respondent activated by several products
counts once for each.

## Usage

``` r
combo_frequency(df, products)
```

## Arguments

- df:

  A data frame or matrix of activations, with one row per respondent and
  one column per product.

- products:

  A character vector of products (column names of `df`).

## Value

A single number: the total frequency.

## Examples

``` r
combo_frequency(am, c("northwind", "may"))
#> [1] 3368
```
