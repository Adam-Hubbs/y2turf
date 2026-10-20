# y2turf

Fast TURF (total unduplicated reach and frequency) analysis.
[`turf()`](https://adam-hubbs.github.io/y2turf/reference/turf.md) finds
the combinations of products that reach the most respondents. It builds
each combination in batches, refined with swap searches, rather than
scoring every possible combination. The search is implemented in Rust
via [savvy](https://github.com/yutannihilation/savvy).

## Installation

Building from source requires a Rust toolchain (`cargo` and `rustc`).
Install it from <https://www.rust-lang.org/tools/install>, then:

``` r

# install.packages("pak")
pak::pak("Adam-Hubbs/y2turf")
```

## Usage

Activation data has one row per respondent and one column per product,
with `1` where a respondent is activated by a product and `0` otherwise.
The package includes a simulated example, `am`.

``` r

library(y2turf)

turf(
  am,
  possible_products = colnames(am),
  num_products = 4,
  batch_size = 2,
  keep_n_at_batch = 10,
  num_return = 3
)
```

The result has one row per combination, best first, with its `products`,
`total_reach`, and `total_frequency`. See
[`?turf`](https://adam-hubbs.github.io/y2turf/reference/turf.md) for how
the search works and how its arguments trade speed against thoroughness.

## Development

The Rust source lives in `src/rust/src/`. `R/000-wrappers.R`,
`src/init.c`, and `src/rust/api.h` are generated from it, so don’t edit
them by hand.

- After changing a `#[savvy]` function’s signature or docs, run
  `savvy::savvy_update()` to regenerate the bindings, then
  `devtools::document()`.
- Build only through R (`devtools::document()`, `devtools::load_all()`,
  `devtools::install()`), not bare `cargo build`, which lacks the
  environment R’s build tools provide. `cargo clippy` and `cargo fmt`
  are fine.
- Builds always use the release profile, so timings reflect real
  performance. Set `SAVVY_PROFILE=dev` for a debug build.
- To clean the build, delete `src/rust/target`. Don’t use
  `devtools::clean_dll()`: it deletes compiled files inside
  `src/rust/target` that cargo doesn’t know to rebuild, and the next
  build fails with “could not find native static library
  `unwind_protect`”. Deleting `src/rust/target` fixes it.
