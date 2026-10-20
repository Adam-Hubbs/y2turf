# Count the respondents reached

Counts the respondents marked as reached by
[`get_activations()`](https://adam-hubbs.github.io/y2turf/reference/get_activations.md).
On the full data this is a combination's reach. On data limited to
respondents not already reached by some other products, it is the
combination's marginal reach: how many new respondents it adds.

## Usage

``` r
marginal_activations(vec)
```

## Arguments

- vec:

  A logical vector from
  [`get_activations()`](https://adam-hubbs.github.io/y2turf/reference/get_activations.md).

## Value

A single integer: the number of respondents reached.

## Examples

``` r
# Reach of a combination
marginal_activations(get_activations(am, c("northwind", "may")))
#> [1] 3210

# Respondents "may" adds beyond those "northwind" already reaches
not_reached <- am[!get_activations(am, "northwind"), ]
marginal_activations(get_activations(not_reached, "may"))
#> [1] 1854
```
