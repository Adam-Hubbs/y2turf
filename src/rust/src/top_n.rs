//! Keeping the best candidates.
//!
//! Every search in this crate ranks combinations the same way: more reach,
//! then more frequency, then the lexicographically smaller combination. That
//! ordering is total, so "the best `n`" is always unambiguous.

use std::cmp::{Ordering, Reverse};
use std::collections::BinaryHeap;
use std::fmt;

use rayon::prelude::*;

use crate::bitsets::Bitsets;

/// A scored combination. `combo` holds product positions, ascending.
#[derive(PartialEq, Eq)]
pub struct Candidate {
    pub reach: u32,
    pub frequency: u32,
    pub combo: Vec<u32>,
}

impl fmt::Display for Candidate {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let combos: Vec<String> = self.combo.iter().map(|c| c.to_string()).collect();

        write!(
            f,
            "Combination: {}, Reach: {}, Frequency: {}",
            combos.join(","),
            self.reach,
            self.frequency
        )
    }
}

/// Orders candidates worst-to-best, so `a > b` reads as "a is the better
/// result": more reach, then more frequency, then earlier in product order.
impl Ord for Candidate {
    fn cmp(&self, other: &Self) -> Ordering {
        self.reach
            .cmp(&other.reach)
            .then_with(|| self.frequency.cmp(&other.frequency))
            .then_with(|| other.combo.cmp(&self.combo))
    }
}

impl PartialOrd for Candidate {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

/// The best `capacity` candidates seen so far.
///
/// A min-heap on candidate quality, so the one at risk of eviction is always
/// the one on top.
pub struct TopN {
    capacity: usize,
    heap: BinaryHeap<Reverse<Candidate>>,
}

impl TopN {
    pub fn new(capacity: usize) -> Self {
        Self {
            capacity,
            heap: BinaryHeap::with_capacity(capacity + 1),
        }
    }

    /// Offers a candidate as its parts rather than as a `Candidate`, so the
    /// `combo` vector is only allocated for the rare candidate worth keeping.
    pub fn offer(&mut self, reach: u32, frequency: u32, chosen: &[u32], last: u32) {
        if self.is_full() && !self.beats_worst(reach, frequency, chosen, last) {
            return;
        }

        self.push(Candidate {
            reach,
            frequency,
            combo: chosen
                .iter()
                .copied()
                .chain(std::iter::once(last))
                .collect(),
        });
    }

    /// Offers an already-built candidate.
    pub fn insert(&mut self, candidate: Candidate) {
        let keep = !self.is_full() || self.heap.peek().is_none_or(|worst| candidate > worst.0);
        if keep {
            self.push(candidate);
        }
    }

    pub fn merge(&mut self, other: TopN) {
        for Reverse(candidate) in other.heap {
            self.insert(candidate);
        }
    }

    #[inline(always)]
    fn is_full(&self) -> bool {
        self.heap.len() >= self.capacity
    }

    #[inline(always)]
    fn beats_worst(&self, reach: u32, frequency: u32, chosen: &[u32], last: u32) -> bool {
        let Some(Reverse(worst)) = self.heap.peek() else {
            return true;
        };

        match (reach, frequency).cmp(&(worst.reach, worst.frequency)) {
            Ordering::Greater => true,
            Ordering::Less => false,
            Ordering::Equal => chosen
                .iter()
                .chain(std::iter::once(&last))
                .lt(worst.combo.iter()),
        }
    }

    fn push(&mut self, candidate: Candidate) {
        self.heap.push(Reverse(candidate));
        if self.heap.len() > self.capacity {
            self.heap.pop();
        }
    }

    /// Best first. A heap of `Reverse` sorts ascending by `Reverse`, which is
    /// descending by candidate quality.
    pub fn into_ranked(self) -> Vec<Candidate> {
        self.heap
            .into_sorted_vec()
            .into_iter()
            .map(|Reverse(candidate)| candidate)
            .collect()
    }
}

/// Scores each of `combos` against `products` and returns the best `n`, best
/// first.
pub fn rank_combos(
    products: &Bitsets,
    combos: impl IntoParallelIterator<Item = Vec<u32>>,
    n: usize,
) -> Vec<Candidate> {
    combos
        .into_par_iter()
        .fold(
            || TopN::new(n),
            |mut top, combo| {
                let (reach, frequency) = products.score(&combo);
                top.insert(Candidate {
                    reach,
                    frequency,
                    combo,
                });
                top
            },
        )
        .reduce(
            || TopN::new(n),
            |mut top, other| {
                top.merge(other);
                top
            },
        )
        .into_ranked()
}
