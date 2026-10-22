# Extract one combination from a turf result

Pulls the products of a single combination out of a
[`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md) result
as a character vector, ready to pass to
[`order_products()`](https://adam-hubbs.github.io/y2turf/reference/order_products.md).

## Usage

``` r
extract_combination(result, rank = 1)
```

## Arguments

- result:

  A data frame returned by
  [`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md).

- rank:

  The rank of the combination to extract. Defaults to `1`, the top
  combination.

## Value

A character vector of products, in the order
[`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md)
returned them (descending solo reach).

## See also

[`order_products()`](https://adam-hubbs.github.io/y2turf/reference/order_products.md)
to order and score the extracted products.

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
extract_combination(result)
#> [1] "southwind" "coi"       "lemon"     "may"      
extract_combination(result, rank = 2)
#> [1] "southwind" "coi"       "lemon"     "green"    
```
