//! The full TURF search: a sequence of batches, each optionally refined by
//! swaps.
//!
//! Each batch fixes the products found so far and searches every way of
//! adding `size` more (see [`crate::batch`]). From the second batch on, swaps
//! (see [`crate::swap`]) may then reshuffle the whole combination, fixed
//! products included. The best combination after each batch is fixed for the
//! next, and the final batch's ranking is the result.
//!
//! Internally products are numbered in canonical order: descending solo
//! reach, ties broken by column order. So a combination stored ascending is
//! already in display order, and ties between otherwise equal candidates go
//! to the more popular products.

use std::cmp::Reverse;

use savvy::savvy;
use savvy::{IntegerSexp, OwnedIntegerSexp, OwnedListSexp, OwnedLogicalSexp, OwnedRealSexp};

use crate::batch::run_batch;
use crate::bitsets::Bitsets;
use crate::swap::swap_until_stable;
use crate::top_n::{Candidate, rank_combos};

/// What to search for, and how.
struct Settings {
    /// Products added by each batch, in order. Sums to the combination size.
    batch_sizes: Vec<usize>,
    /// Combinations each batch keeps (and hands to the swap search).
    keep_n: usize,
    /// Combinations to return.
    num_return: usize,
    use_swaps: bool,
    /// Combinations each swap search keeps.
    swap_top_n: usize,
}

/// The outcome of a full search.
struct Turf {
    /// The best `num_return` combinations, best first, each holding column
    /// indexes in canonical order.
    ranked: Vec<Candidate>,
    /// Combinations scored by batches.
    n_regular: f64,
    /// Combinations scored by swaps.
    n_swap: f64,
    /// Whether every swap search settled.
    converged: bool,
}

/// Runs the full search over the columns of the `nrow` by `ncol`
/// column-major `data`.
fn run_turf(data: &[i32], nrow: usize, ncol: usize, settings: &Settings) -> Turf {
    let columns = canonical_order(data, nrow, ncol);
    let to_columns = |positions: &[u32]| -> Vec<usize> {
        positions.iter().map(|&p| columns[p as usize]).collect()
    };

    let all_rows: Vec<usize> = (0..nrow).collect();
    let everyone = Bitsets::build(data, nrow, &columns, &all_rows);

    let mut fixed: Vec<u32> = Vec::new();
    let mut ranked = Vec::new();
    let mut n_regular = 0.0;
    let mut n_swap = 0.0;
    let mut converged = true;

    for (i, &size) in settings.batch_sizes.iter().enumerate() {
        // The final batch's ranking is the result, so it must hold at least
        // `num_return` combinations.
        let is_final = i + 1 == settings.batch_sizes.len();
        let widen = |n: usize| {
            if is_final {
                n.max(settings.num_return)
            } else {
                n
            }
        };
        let keep_n = widen(settings.keep_n);

        let open: Vec<u32> = (0..ncol as u32)
            .filter(|p| fixed.binary_search(p).is_err())
            .collect();
        let batch = run_batch(
            data,
            nrow,
            &to_columns(&open),
            &to_columns(&fixed),
            size,
            keep_n,
        );
        n_regular += batch.n_combinations;

        let complete: Vec<Vec<u32>> = batch
            .ranked
            .iter()
            .map(|candidate| {
                let added = candidate.combo.iter().map(|&p| open[p as usize]);
                let mut combo: Vec<u32> = fixed.iter().copied().chain(added).collect();
                combo.sort_unstable();
                combo
            })
            .collect();

        // Either way, complete combinations are rescored against everyone, so
        // they rank by total (not marginal) reach and frequency.
        ranked = if settings.use_swaps && i > 0 {
            let swapped = swap_until_stable(&everyone, complete, widen(settings.swap_top_n));
            n_swap += swapped.n_combinations;
            converged &= swapped.converged;
            swapped.ranked
        } else {
            rank_combos(&everyone, complete, keep_n)
        };

        fixed.clone_from(&ranked[0].combo);
    }

    ranked.truncate(settings.num_return);
    for candidate in &mut ranked {
        for p in &mut candidate.combo {
            *p = columns[*p as usize] as u32;
        }
    }

    Turf {
        ranked,
        n_regular,
        n_swap,
        converged,
    }
}

/// Column indexes ordered by descending solo reach, ties by column order.
fn canonical_order(data: &[i32], nrow: usize, ncol: usize) -> Vec<usize> {
    let reach: Vec<usize> = (0..ncol)
        .map(|column| {
            data[column * nrow..(column + 1) * nrow]
                .iter()
                .filter(|&&value| value != 0)
                .count()
        })
        .collect();

    let mut order: Vec<usize> = (0..ncol).collect();
    order.sort_by_key(|&column| Reverse(reach[column]));
    order
}

// ---------------------------------------------------------------------------
// R interface
// ---------------------------------------------------------------------------

/// Full TURF Search
///
/// Runs every batch, with optional swaps, over all columns of `x`, and returns
/// the best `num_return` combinations ordered by decreasing total reach, then
/// decreasing total frequency, then products' solo reach.
///
/// @param x An integer matrix containing only `0` and `1`, respondents in rows
///   and products in columns.
/// @param batch_sizes An integer vector: how many products each batch adds.
///   Must sum to at most `ncol(x)`.
/// @param keep_n Combinations each batch keeps.
/// @param num_return Combinations to return.
/// @param use_swaps Whether to refine every batch after the first with swaps.
/// @param swap_top_n Combinations each swap search keeps.
/// @returns A list with `combos` (an integer matrix, one row per product by
///   one column per returned combination, holding 1-based column indexes into
///   `x` ordered by descending solo reach), `reach` (integer total reach),
///   `frequency` (double total activations), `n_regular` and `n_swap` (doubles:
///   combinations scored by batches and by swaps), and `converged` (whether
///   every swap search settled).
/// @noRd
#[savvy]
fn turf_search(
    x: IntegerSexp,
    batch_sizes: IntegerSexp,
    keep_n: i32,
    num_return: i32,
    use_swaps: bool,
    swap_top_n: i32,
) -> savvy::Result<savvy::Sexp> {
    let dim = x
        .get_dim()
        .ok_or_else(|| savvy::Error::new("`x` must be a matrix"))?;
    let (nrow, ncol) = (dim[0] as usize, dim[1] as usize);

    if batch_sizes.as_slice().is_empty() || batch_sizes.iter().any(|&size| size < 1) {
        return Err(savvy::Error::new(
            "`batch_sizes` must be a non-empty vector of positive integers.",
        ));
    }
    let batch_sizes: Vec<usize> = batch_sizes.iter().map(|&size| size as usize).collect();
    let size: usize = batch_sizes.iter().sum();
    if size > ncol {
        return Err(savvy::Error::new(
            "`sum(batch_sizes)` must not exceed `ncol(x)`.",
        ));
    }
    if keep_n < 1 || num_return < 1 || swap_top_n < 1 {
        return Err(savvy::Error::new(
            "`keep_n`, `num_return`, and `swap_top_n` must be positive.",
        ));
    }

    let settings = Settings {
        batch_sizes,
        keep_n: keep_n as usize,
        num_return: num_return as usize,
        use_swaps,
        swap_top_n: swap_top_n as usize,
    };
    let turf = run_turf(x.as_slice(), nrow, ncol, &settings);
    let ranked = &turf.ranked;

    let mut combos_out = OwnedIntegerSexp::new(ranked.len() * size)?;
    let mut reach_out = OwnedIntegerSexp::new(ranked.len())?;
    let mut frequency_out = OwnedRealSexp::new(ranked.len())?;
    for (rank, candidate) in ranked.iter().enumerate() {
        reach_out[rank] = candidate.reach as i32;
        frequency_out[rank] = candidate.frequency as f64;
        for (row, &column) in candidate.combo.iter().enumerate() {
            combos_out[rank * size + row] = column as i32 + 1;
        }
    }
    combos_out.set_dim(&[size, ranked.len()])?;

    let mut out = OwnedListSexp::new(6, true)?;
    out.set_name_and_value(0, "combos", combos_out)?;
    out.set_name_and_value(1, "reach", reach_out)?;
    out.set_name_and_value(2, "frequency", frequency_out)?;
    out.set_name_and_value(
        3,
        "n_regular",
        OwnedRealSexp::try_from_scalar(turf.n_regular)?,
    )?;
    out.set_name_and_value(4, "n_swap", OwnedRealSexp::try_from_scalar(turf.n_swap)?)?;
    out.set_name_and_value(
        5,
        "converged",
        OwnedLogicalSexp::try_from_scalar(turf.converged)?,
    )?;

    Ok(out.into())
}
