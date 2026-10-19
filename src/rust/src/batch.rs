//! TURF batch search.
//!
//! Scores every combination of `size` products and keeps the best `keep_n`.
//!
//! Three ideas carry the performance, in order of importance:
//!
//! 1. Respondents are bits (see [`crate::bitsets`]). A combination is scored
//!    with bitwise ORs and popcounts.
//!
//! 2. Combinations are never materialised. The search walks them depth-first
//!    in lexicographic order, carrying the OR of the products chosen so far.
//!    The work done at `{a, b}` is shared by every `{a, b, *}` beneath it, so a
//!    leaf costs one OR + popcount regardless of `size`.
//!
//! 3. Only the winners are stored, in a bounded heap of `keep_n` candidates.
//!
//! Everything is scored against "active" respondents only: those not already
//! reached by the fixed set, since those can contribute no marginal reach.

use rayon::prelude::*;
use savvy::savvy;
use savvy::{IntegerSexp, OwnedIntegerSexp, OwnedListSexp, OwnedRealSexp};

use crate::bitsets::{Bitsets, union_count, union_into};
use crate::top_n::{Candidate, TopN};

/// The outcome of one batch.
pub struct Batch {
    /// The best combinations, best first, as positions in the searched
    /// products.
    pub ranked: Vec<Candidate>,
    /// How many combinations were scored.
    pub n_combinations: f64,
}

/// Finds the best `keep_n` combinations of `size` products drawn from
/// `products`, by reach over the respondents `fixed` doesn't already reach.
/// Both are column indexes into the `nrow`-row column-major `data`. Requires
/// `1 <= size <= products.len()`.
pub fn run_batch(
    data: &[i32],
    nrow: usize,
    products: &[usize],
    fixed: &[usize],
    size: usize,
    keep_n: usize,
) -> Batch {
    let active = active_rows(data, nrow, fixed);
    let bitsets = Bitsets::build(data, nrow, products, &active);

    Batch {
        ranked: search_all(&bitsets, size, keep_n).into_ranked(),
        n_combinations: n_combinations(products.len(), size),
    }
}

/// Extends `chosen` with `remaining` more products drawn from `start..`,
/// scoring each completed combination.
///
/// `reached` is the union of the products in `chosen` and `frequency` their
/// total activations; both are handed down so a child never recomputes what
/// its parent already knows. `scratch` supplies one `words`-sized slot per
/// level still to come, which is what lets the recursion allocate nothing.
#[allow(clippy::too_many_arguments)]
fn search(
    reached: &[u64],
    frequency: u32,
    remaining: usize,
    start: usize,
    products: &Bitsets,
    chosen: &mut Vec<u32>,
    scratch: &mut [u64],
    top: &mut TopN,
) {
    // The last product is handled here rather than by recursing once more:
    // scoring it needs only the popcount of the union, never the union itself.
    if remaining == 1 {
        for p in start..products.n_products {
            top.offer(
                union_count(reached, products.get(p)),
                frequency + products.counts[p],
                chosen,
                p as u32,
            );
        }
        return;
    }

    let (slot, deeper) = scratch.split_at_mut(products.words);

    // Stop where too few products remain to finish the combination.
    for p in start..=(products.n_products - remaining) {
        union_into(slot, reached, products.get(p));
        chosen.push(p as u32);
        search(
            slot,
            frequency + products.counts[p],
            remaining - 1,
            p + 1,
            products,
            chosen,
            deeper,
            top,
        );
        chosen.pop();
    }
}

/// Runs the search over every combination, splitting the work by first product.
fn search_all(products: &Bitsets, size: usize, keep_n: usize) -> TopN {
    (0..=(products.n_products - size))
        .into_par_iter()
        .fold(
            || TopN::new(keep_n),
            |mut top, first| {
                let count = products.counts[first];

                if size == 1 {
                    top.offer(count, count, &[], first as u32);
                    return top;
                }

                let mut scratch = vec![0u64; size * products.words];
                let (reached, deeper) = scratch.split_at_mut(products.words);
                reached.copy_from_slice(products.get(first));

                let mut chosen = Vec::with_capacity(size);
                chosen.push(first as u32);

                search(
                    reached,
                    count,
                    size - 1,
                    first + 1,
                    products,
                    &mut chosen,
                    deeper,
                    &mut top,
                );
                top
            },
        )
        .reduce(
            || TopN::new(keep_n),
            |mut top, other| {
                top.merge(other);
                top
            },
        )
}

/// Rows not reached by any fixed product. These are the only rows that can
/// contribute marginal reach.
fn active_rows(data: &[i32], nrow: usize, fixed: &[usize]) -> Vec<usize> {
    (0..nrow)
        .filter(|&row| !fixed.iter().any(|&column| data[column * nrow + row] != 0))
        .collect()
}

fn n_combinations(n: usize, size: usize) -> f64 {
    (0..size)
        .fold(1.0f64, |total, i| total * (n - i) as f64 / (i + 1) as f64)
        .round()
}

// ---------------------------------------------------------------------------
// R interface
// ---------------------------------------------------------------------------

/// TURF Batch Search
///
/// Scores every combination of `size` products drawn from `products` by the
/// number of respondents it reaches beyond those already reached by `fixed`,
/// and returns the best `keep_n`, ordered by decreasing reach, then decreasing
/// frequency (total activations), then the order products were supplied in.
///
/// @param x An integer matrix containing only `0` and `1`, respondents in rows
///   and products in columns.
/// @param products An integer vector of 1-based column indexes to search over.
///   Must not overlap `fixed`.
/// @param fixed An integer vector of 1-based column indexes already selected;
///   length 0 for none. Respondents these reach are dropped before scoring.
/// @param size Number of products per combination.
/// @param keep_n Number of top combinations to keep.
/// @returns A list with `combos` (an integer matrix, `size` rows by one column
///   per kept combination, holding 1-based column indexes into `x`), `reach`
///   (integer marginal reach per kept combination), and `n_combinations` (a
///   double: the number of candidates searched, before trimming to `keep_n`).
/// @noRd
#[savvy]
fn turf_run_batch(
    x: IntegerSexp,
    products: IntegerSexp,
    fixed: IntegerSexp,
    size: i32,
    keep_n: i32,
) -> savvy::Result<savvy::Sexp> {
    let dim = x
        .get_dim()
        .ok_or_else(|| savvy::Error::new("`x` must be a matrix"))?;
    let nrow = dim[0] as usize;

    let columns: Vec<usize> = products.iter().map(|&p| (p - 1) as usize).collect();
    let fixed: Vec<usize> = fixed.iter().map(|&p| (p - 1) as usize).collect();
    let size = size as usize;

    if size == 0 || size > columns.len() {
        return Err(savvy::Error::new(
            "`size` must be between 1 and `length(products)`.",
        ));
    }

    let batch = run_batch(
        x.as_slice(),
        nrow,
        &columns,
        &fixed,
        size,
        keep_n.max(0) as usize,
    );
    let ranked = &batch.ranked;

    let mut combos_out = OwnedIntegerSexp::new(ranked.len() * size)?;
    let mut reach_out = OwnedIntegerSexp::new(ranked.len())?;
    for (rank, candidate) in ranked.iter().enumerate() {
        reach_out[rank] = candidate.reach as i32;
        for (row, &p) in candidate.combo.iter().enumerate() {
            combos_out[rank * size + row] = columns[p as usize] as i32 + 1;
        }
    }
    combos_out.set_dim(&[size, ranked.len()])?;

    let mut out = OwnedListSexp::new(3, true)?;
    out.set_name_and_value(0, "combos", combos_out)?;
    out.set_name_and_value(1, "reach", reach_out)?;
    out.set_name_and_value(
        2,
        "n_combinations",
        OwnedRealSexp::try_from_scalar(batch.n_combinations)?,
    )?;

    Ok(out.into())
}
