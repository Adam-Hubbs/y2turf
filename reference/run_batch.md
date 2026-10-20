# Run a single batch of a TURF analysis

Scores every combination of `size` products drawn from
`possible_products` (excluding `fixed`) by marginal reach: the number of
respondents it reaches who are not already reached by `fixed`. This is
one step of
[`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md),
exposed for inspection.

## Usage

``` r
run_batch(df, possible_products, size, fixed = NA, keep_n = 20)
```

## Arguments

- df:

  A data frame or matrix of activations, with one row per respondent and
  one column per product. Columns named in `possible_products` or
  `fixed` must contain only `0` and `1`. Other columns are ignored.

- possible_products:

  A character vector of the products (column names of `df`) to choose
  from.

- size:

  The number of products in each combination. A positive integer no
  greater than the number of products in `possible_products` but not in
  `fixed`.

- fixed:

  A character vector of products already chosen, or `NA` for none.

- keep_n:

  The number of combinations to keep. A positive integer.

## Value

A list with elements:

- `combos`: a character matrix with `size` rows and one column per kept
  combination, best first.

- `reach`: an integer vector of each kept combination's marginal reach.

- `n_combinations`: the number of combinations scored.

## Details

Combinations are ranked by marginal reach, then marginal frequency
(total activations among respondents not reached by `fixed`), then the
order of their products in `possible_products`. Scoring runs in Rust.

## Examples

``` r
batch <- run_batch(am, colnames(am), size = 2, keep_n = 3)
batch$combos
#>      [,1]        [,2]        [,3]       
#> [1,] "southwind" "southwind" "southwind"
#> [2,] "coi"       "lemon"     "may"      

# The best products to add to the current leader
run_batch(am, colnames(am), size = 1, fixed = batch$combos[, 1], keep_n = 3)
#> $combos
#>      [,1]    [,2]  [,3]   
#> [1,] "lemon" "may" "green"
#> 
#> $reach
#> [1] 1587 1544 1526
#> 
#> $n_combinations
#> [1] 51
#> 
```
