# Run a TURF analysis

TURF (total unduplicated reach and frequency) analysis looks for the
combination of `num_products` products that reaches the most
respondents, where a respondent is reached if they are activated by
(would choose) at least one product in the combination. `turf()` returns
the best `num_return` combinations.

Scoring every combination quickly becomes infeasible: 53 products have
886 million combinations of 8. Instead, `turf()` builds combinations up
in batches and repairs them with a local swap search, scoring only a
small fraction of all combinations. This usually finds the best
combination, but unless `batch_size = num_products` it is not guaranteed
to. The sections below explain each step.

## Usage

``` r
turf(
  df,
  possible_products,
  num_products,
  batch_size,
  keep_n_at_batch,
  num_return = 1,
  show_combinations = TRUE,
  use_swaps = TRUE,
  swap_top_n = 3
)
```

## Arguments

- df:

  A data frame of activations, with one row per respondent and one
  column per product. Columns named in `possible_products` must contain
  only `0` and `1`. Other columns are ignored.

- possible_products:

  A character vector of the products (column names of `df`) to choose
  from.

- num_products:

  The number of products in each combination. A positive integer no
  greater than `length(possible_products)`.

- batch_size:

  The number of products each batch adds. A positive integer. The final
  batch may be enlarged to make sure `num_return` combinations can be
  returned.

- keep_n_at_batch:

  The number of combinations each batch keeps; these seed the swap
  search. A positive integer. The final batch keeps at least
  `num_return`.

- num_return:

  The number of combinations to return. A positive integer.

- show_combinations:

  Whether to report how many combinations were searched, and attach the
  counts to the result as attributes. A boolean.

- use_swaps:

  Whether to refine every batch after the first with a swap search. A
  boolean.

- swap_top_n:

  The number of combinations the swap search keeps (and swaps from) each
  round. A positive integer. The final swap search keeps at least
  `num_return`.

## Value

A tibble with one row per combination, best first, and columns:

- `rank`: integer rank, starting at 1.

- `products`: a list of character vectors, each holding a combination's
  products in descending order of individual reach.

- `total_reach`: the number of respondents reached by the combination.

- `total_frequency`: the total number of activations across the
  combination's products.

When `show_combinations = TRUE`, the attributes `n_combinations`,
`n_regular_combinations`, and `n_swap_combinations` hold the number of
combinations scored in total, by batches, and by swaps.

## Reach and frequency

A combination's *reach* is the number of respondents activated by at
least one of its products. Its *frequency* is its total number of
activations, so a respondent activated by two of its products counts
twice:

                     respondent   1 2 3 4 5 6
      product A                   1 1 0 0 0 0
      product B                   0 1 1 1 0 0
      {A, B} reaches              x x x x . .    reach 4, frequency 5

Given products already chosen, a candidate's *marginal reach* is the
number of respondents it reaches that the chosen products don't. Above,
B's marginal reach given A is 2 (respondents 3 and 4).

## Overview

      put products in order of individual reach
                          |
                          v
      plan batch sizes          e.g. 7 products in batches of 3: 3, 3, 1
                          |
                          v
      +-- for each batch ------------------------------------------+
      |  1. score every way of adding `size` products to the fixed |
      |     set F by marginal reach, and keep the best             |
      |     `keep_n_at_batch`                                      |
      |  2. complete each kept combination with F                  |
      |  3. after the first batch, if `use_swaps`: swap search     |
      |  4. fix the best combination as F for the next batch       |
      +------------------------------------------------------------+
                          |
                          v
      return the final batch's best `num_return` combinations

## Planning batches

The `num_products` products are found in batches of `batch_size`, with
the final batch taking the remainder. Each batch chooses only among
products not chosen yet:

      53 products, num_products = 7, batch_size = 3

      batch 1:  best 3 of 53                          F = {a, b, c}
      batch 2:  best 3 of the other 50, given F       F = {a, b, c, d, e, f}
      batch 3:  best 1 of the other 47, given F       -> results

The final batch must be able to produce `num_return` distinct
combinations. If it can't, it is combined with the batch before it
(repeatedly, if needed), with a warning. For example, 5 products in
batches of 2 would be batches of 2, 2, and 1, but the final batch has
only 49 products to choose from. With `num_return = 60`, the last two
batches are combined into one of 3, which has `choose(51, 3)` = 20,825
candidates, giving batches of 2 and 3.

## Scoring a batch

Respondents already reached by the fixed set F can't add to any
candidate's reach, so they are set aside and candidates are scored by
marginal reach among the rest:

                 respondent   1 2 3 4 5 6 7 8 9 10
      F = {A}                 x x x x x x . . . .
      still to reach                      7 8 9 10

      add B                   1 1 1 0 0 0 1 1 0 0    +2  (7, 8)
      add C                   0 0 0 1 1 1 0 0 1 1    +2  (9, 10)
      add D                   1 0 0 0 0 0 0 0 0 0    +0

Every combination of `size` remaining products is scored; nothing is
pruned. The best `keep_n_at_batch` (at least `num_return` in the final
batch) are kept and completed with F. Every candidate shares F, so
ranking them by marginal reach is the same as ranking them by total
reach.

Without swaps, each batch is a greedy step: it commits to the best
`batch_size` products given what was already chosen, and never revisits
that choice.

## Swap search

Greedy steps can lock in an early choice that turns out to be poor. With
batches of 1:

                 respondent   1 2 3 4 5 6 7 8 9 10    reach
      A                       1 1 1 1 1 1 0 0 0 0       6
      B                       1 1 1 0 0 0 1 1 0 0       5
      C                       0 0 0 1 1 1 0 0 1 1       5

      batch 1 picks A (best alone); batch 2 adds B or C     -> 8
      swapping A for C turns {A, B} into {B, C}             -> 10

So when `use_swaps = TRUE`, every batch after the first is followed by a
swap search over complete combinations, starting from the batch's kept
combinations. Each round generates every combination one swap away from
a kept combination: any one product, including products fixed by earlier
batches, is replaced with any product not in the combination.

      products A, B, C, D; kept combination {A, B}

      swap out A:   {C, B}   {D, B}
      swap out B:   {A, C}   {A, D}

These swaps are pooled with the kept combinations themselves, and the
best `swap_top_n` (at least `num_return` in the final batch) are kept
for the next round:

      round 1:   K1  ->  K1 + every swap of K1  ->  best swap_top_n  =  K2
      round 2:   K2  ->  K2 + every swap of K2  ->  best swap_top_n  =  K3
      ...
      stop when a round keeps what it started with (K3 = K2)

Since the kept combinations are always in the pool, results never get
worse from one round to the next. When the search stops, no swap of any
kept combination beats the worst of them; in particular, no single swap
improves the best combination. The search gives up after 50 rounds, with
a warning, and returns the best combinations found so far.

The first batch is never followed by a swap search: it already scored
every combination of its size, and a swap only produces another
combination of the same size.

## Ranking and ties

Combinations are ranked by total reach, then by total frequency. Any
remaining ties go to the combination whose products have higher
individual reach. Products are put in order of individual reach (ties
broken by their order in `possible_products`), and tied combinations are
compared product by product in that order. Each returned combination
lists its products in this order. Within a batch, candidates are ranked
the same way, using marginal rather than total reach and frequency.

## Combinations searched

With `show_combinations = TRUE`, `turf()` reports how many combinations
it scored. *Regular* combinations are those scored by batches: for each
batch, `choose(remaining products, batch size)`. *Swap* combinations are
those generated by swap searches, with duplicates removed within each
round but not across rounds.

## Choosing the arguments

- `batch_size` matters most. Larger batches look further ahead, so they
  are less likely to lock in a poor choice, and
  `batch_size = num_products` scores every combination, guaranteeing the
  best result. But the cost grows very fast: each batch scores
  `choose(remaining products, batch_size)` combinations (see below).

- `use_swaps` repairs poor choices made by earlier batches, usually at
  small cost.

- `keep_n_at_batch` gives the swap search more starting points, at small
  cost.

- `swap_top_n` widens the swap search, so it explores more alternatives
  before stopping. Each round scores about `swap_top_n * k * (n - k)`
  combinations of `k` of `n` products.

Combinations of each size among 53 products:

|      |              |
|------|--------------|
| Size | Combinations |
| 1    | 53           |
| 2    | 1,378        |
| 3    | 23,426       |
| 4    | 292,825      |
| 5    | 2,869,685    |
| 6    | 22,957,480   |
| 8    | 886,322,710  |

A practical approach is to start with small batches and swaps, then
check whether larger batches (or a larger `swap_top_n`) change the
result.

## Implementation

The search runs in Rust, and relies on three ideas.

**Respondents as bits.** Each product is stored as a bitset with one bit
per respondent, 64 respondents to a machine word. A combination's reach
is the number of set bits in the OR of its products' bitsets, and its
frequency is the sum of per-product counts computed once up front:

      respondent   1 2 3 4 5 6 7 8
      A            1 1 1 1 1 1 0 0
      B            1 1 1 0 0 0 1 1
      A OR B       1 1 1 1 1 1 1 1     set bits = reach = 8

For a batch, the bitsets cover only respondents not reached by F, so set
bits count marginal reach directly, and the bitsets shrink as F grows.

**Shared work.** A batch's combinations are visited depth first, in
lexicographic order, carrying the OR of the products chosen so far. The
OR for `{a, b}` is computed once and shared by every `{a, b, ...}` below
it, so each combination costs a single OR and count, whatever its size:

      {a} --+-- {a, b} --+-- {a, b, c}
            |            +-- {a, b, d}
            |            +-- {a, b, e}
            +-- {a, c} --+-- {a, c, d}
            |            +-- {a, c, e}
            +-- {a, d} ----- {a, d, e}
      {b} --+-- {b, c} --+-- {b, c, d}
      ...

**Bounded memory.** Combinations are never stored in bulk. Each one is
scored as it is visited, and only the best are kept, in a fixed-size
heap. The work is split across threads by first product, and swaps are
also scored in parallel.

## See also

[`run_batch()`](https://adam-hubbs.github.io/y2turf/reference/run_batch.md)
to run a single batch.

## Examples

``` r
turf(
  am,
  colnames(am),
  num_products = 4,
  batch_size = 2,
  keep_n_at_batch = 10,
  num_return = 3
)
#> Searched 4358 combinations: 2653 regular combinations and 1705 swap
#> combinations across 2 batches.
#> # A tibble: 3 × 4
#>    rank products  total_reach total_frequency
#>   <int> <list>          <int>           <dbl>
#> 1     1 <chr [4]>        6856            8174
#> 2     2 <chr [4]>        6842            8139
#> 3     3 <chr [4]>        6835            8078

# One batch of every product scores every combination: exact, but the
# number of combinations grows very quickly with `num_products`
turf(
  am,
  colnames(am),
  num_products = 3,
  batch_size = 3,
  keep_n_at_batch = 10,
  num_return = 3
)
#> Searched 23426 combinations: 23426 regular combinations and 0 swap combinations
#> across 1 batch.
#> # A tibble: 3 × 4
#>    rank products  total_reach total_frequency
#>   <int> <list>          <int>           <dbl>
#> 1     1 <chr [3]>        5498            6162
#> 2     2 <chr [3]>        5455            6147
#> 3     3 <chr [3]>        5441            6145
```
