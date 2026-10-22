# Order a combination's products by reach, then marginal reach

Orders the products of one combination greedily and reports how reach
builds up one product at a time. The first product in `products` is kept
first: in a
[`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md) result
it has the highest solo reach. Each later step adds the remaining
product that reaches the most respondents not already reached. Ties are
broken by solo reach, then by position in `products`.

## Usage

``` r
order_products(df, products)
```

## Arguments

- df:

  A data frame of 0/1 activations, with one row per respondent and one
  column per product, as passed to
  [`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md).

- products:

  A character vector of products (column names of `df`) in one
  combination, for example from
  [`extract_combination()`](https://adam-hubbs.github.io/y2turf/reference/extract_combination.md).

## Value

A tibble with one row per product, in greedy order:

- `step`: position in the order.

- `product`: the product added at this step.

- `solo_reach`: percent of respondents the product reaches alone.

- `marginal_reach`: percent of respondents the product adds beyond the
  earlier steps.

- `total_reach`: percent of respondents reached by this and all earlier
  steps. The last row equals the combination's reach.

- `frequency`: total activations across this and all earlier steps, as a
  percent of respondents. Unlike reach, it can exceed 100.

## Details

All measures are percentages of the respondents in `df` (0 to 100).

## See also

[`extract_combination()`](https://adam-hubbs.github.io/y2turf/reference/extract_combination.md)
to get `products` from a
[`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md)
result.

## Examples

``` r
result <- turf(
  am,
  colnames(am),
  num_products = 4,
  batch_size = 2,
  keep_n_at_batch = 10,
  num_return = 3
)
#> Searched 4,358 combinations: 2,653 regular and 1,705 swap, across 2 batches.
order_products(am, extract_combination(result))
#> # A tibble: 4 × 6
#>    step product   solo_reach marginal_reach total_reach frequency
#>   <int> <chr>          <dbl>          <dbl>       <dbl>     <dbl>
#> 1     1 southwind       14.0          14.0         14.0      14.0
#> 2     2 coi             13.5          12.0         26.1      27.6
#> 3     3 lemon           13.5          10.6         36.7      41.1
#> 4     4 may             13.4           9.05        45.7      54.5
```
