//! Local search by single-product swaps.
//!
//! Starting from complete combinations, each round tries every way of
//! replacing one product with one not yet in the combination, and keeps the
//! best `top_n` of those plus the previous round's winners. Since the winners
//! always stay in the pool, the kept results can only improve. The search
//! stops once a round keeps exactly the combinations it started with.

use std::collections::HashSet;

use crate::bitsets::Bitsets;
use crate::top_n::{Candidate, rank_combos};

/// Rounds to try before giving up on the kept set settling down.
const MAX_ROUNDS: usize = 50;

/// The outcome of a swap search.
pub struct Swapped {
    /// The best combinations found, best first.
    pub ranked: Vec<Candidate>,
    /// How many swapped combinations were scored, deduplicated within each
    /// round (but not across rounds).
    pub n_combinations: f64,
    /// Whether the kept set settled within `MAX_ROUNDS`.
    pub converged: bool,
}

/// Swaps from every combination in `start` (product positions, ascending)
/// until the best `top_n` stop changing.
pub fn swap_until_stable(products: &Bitsets, start: Vec<Vec<u32>>, top_n: usize) -> Swapped {
    let n_start = start.len();
    let mut current = rank_combos(products, start, n_start);
    let mut n_combinations = 0.0;

    for _ in 0..MAX_ROUNDS {
        let mut pool: HashSet<Vec<u32>> = current
            .iter()
            .flat_map(|candidate| neighbors(&candidate.combo, products.n_products))
            .collect();
        n_combinations += pool.len() as f64;
        pool.extend(current.iter().map(|candidate| candidate.combo.clone()));

        let next = rank_combos(products, pool, top_n);
        let settled = same_combos(&current, &next);
        current = next;

        if settled {
            return Swapped {
                ranked: current,
                n_combinations,
                converged: true,
            };
        }
    }

    Swapped {
        ranked: current,
        n_combinations,
        converged: false,
    }
}

/// Every combination one swap away from `combo`, each sorted ascending.
fn neighbors(combo: &[u32], n_products: usize) -> impl Iterator<Item = Vec<u32>> {
    let outside = (0..n_products as u32).filter(move |p| combo.binary_search(p).is_err());

    (0..combo.len()).flat_map(move |slot| {
        outside.clone().map(move |p| {
            let mut swapped = combo.to_vec();
            swapped[slot] = p;
            swapped.sort_unstable();
            swapped
        })
    })
}

/// Whether two rankings hold the same combinations. Ranking is a total order,
/// so the same set always ranks the same way and an element-wise check is
/// enough.
fn same_combos(a: &[Candidate], b: &[Candidate]) -> bool {
    a.iter()
        .map(|candidate| &candidate.combo)
        .eq(b.iter().map(|candidate| &candidate.combo))
}
