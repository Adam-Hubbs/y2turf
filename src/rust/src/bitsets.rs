//! Products as respondent bitsets.
//!
//! Each product becomes a bitset over respondents, so "who does this
//! combination reach?" is a bitwise OR and "how many?" is a popcount. A
//! combination is scored in `nrow / 64` word operations per product.

const WORD_BITS: usize = 64;

/// One bitset per product, each `words` long, laid out end to end.
pub struct Bitsets {
    pub words: usize,
    pub n_products: usize,
    bits: Vec<u64>,
    /// How many respondents each product reaches on its own. Frequency
    /// (total activations, which unlike reach does not dedupe respondents
    /// reached by several products) is just the sum of these across a
    /// combination, so it never needs a pass over respondents.
    pub counts: Vec<u32>,
}

impl Bitsets {
    /// Builds bitsets covering `active` rows only, in the order given by
    /// `products` (column indexes into the `nrow`-row column-major `data`).
    pub fn build(data: &[i32], nrow: usize, products: &[usize], active: &[usize]) -> Self {
        let words = active.len().div_ceil(WORD_BITS);
        let mut bits = vec![0u64; words * products.len()];

        for (p, &column) in products.iter().enumerate() {
            let column = &data[column * nrow..(column + 1) * nrow];
            let bitset = &mut bits[p * words..(p + 1) * words];
            for (bit, &row) in active.iter().enumerate() {
                if column[row] != 0 {
                    bitset[bit / WORD_BITS] |= 1u64 << (bit % WORD_BITS);
                }
            }
        }

        // Not `chunks_exact(words)`: `words` is 0 when no rows are active.
        let counts = (0..products.len())
            .map(|p| {
                bits[p * words..(p + 1) * words]
                    .iter()
                    .map(|word| word.count_ones())
                    .sum()
            })
            .collect();

        Self {
            words,
            n_products: products.len(),
            bits,
            counts,
        }
    }

    #[inline(always)]
    pub fn get(&self, p: usize) -> &[u64] {
        &self.bits[p * self.words..(p + 1) * self.words]
    }

    /// Reach and frequency of `combo`, a set of positions in `products`.
    pub fn score(&self, combo: &[u32]) -> (u32, u32) {
        let reach = (0..self.words)
            .map(|w| {
                combo
                    .iter()
                    .fold(0u64, |word, &p| word | self.get(p as usize)[w])
                    .count_ones()
            })
            .sum();
        let frequency = combo.iter().map(|&p| self.counts[p as usize]).sum();
        (reach, frequency)
    }
}

/// How many respondents `a | b` reaches, without materialising the union.
#[inline(always)]
pub fn union_count(a: &[u64], b: &[u64]) -> u32 {
    a.iter().zip(b).map(|(x, y)| (x | y).count_ones()).sum()
}

#[inline(always)]
pub fn union_into(out: &mut [u64], a: &[u64], b: &[u64]) {
    for (out, (x, y)) in out.iter_mut().zip(a.iter().zip(b)) {
        *out = x | y;
    }
}
