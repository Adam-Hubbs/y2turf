# jarl-ignore-file internal_function: Development purposes only
# Setup -----------------------------------------------

## Packages ---------------------------------------------------------------
library(y2clerk)
library(tidyverse)
library(haven)
library(purrr)
library(labelled)
#pak::pak("y2analytics/y2conjoint")
library(y2conjoint)
library(devtools)
load_all('.')

## Read in data ------------------------------------------------------------
PROJECT_PATH <- "~/Y2 Analytics Dropbox/Y2 Analytics Team Folder/Active Projects_LC/Meta/Wearables/Meta - Wearables - Conjoint Bridging Program - Di/"
DATA_PATH <- str_c(PROJECT_PATH, 'Data/Conjoint/Run 1/')

df <- read_csv(str_c(DATA_PATH, 'RBetas.csv'))

key <- read_rds(
  '~/Y2 Analytics Dropbox/Y2 Analytics Team Folder/Active Projects_LC/Meta/Wearables/Meta - Wearables - Conjoint Bridging Program - Di/Simulator/Data/Conjoint Levels Key.rds'
)

## Create Crosswalk
crosswalk <- tibble::tribble(
  ~old_name , ~user_name           , ~collection_name , ~collection_order ,
  "A1B1"    , "Competitor 1"       , "Product Card"   , NA                ,
  "A1B2"    , "Competitor 2"       , "Product Card"   , NA                ,
  "A1B3"    , "Future Dai"         , "Product Card"   , NA                ,
  "A1B4"    , "Future Oakley"      , "Product Card"   , NA                ,
  "A1B5"    , "HSTN"               , "Product Card"   , NA                ,
  "A1B6"    , "Hypernova 2"        , "Product Card"   , NA                ,
  "A1B7"    , "Luna"               , "Product Card"   , NA                ,
  "A1B8"    , "Modelo"             , "Product Card"   , NA                ,
  "A1B9"    , "OMV"                , "Product Card"   , NA                ,
  "A1B10"   , "MRBD"               , "Product Card"   , NA                ,
  "A1B11"   , "RBM 1"              , "Product Card"   , NA                ,
  "A1B12"   , "RBM 2"              , "Product Card"   , NA                ,
  "A1B13"   , "RBM 2 Optics"       , "Product Card"   , NA                ,
  "A1B14"   , "RBM 4"              , "Product Card"   , NA                ,
  "A1B15"   , "Rectangular Oakley" , "Product Card"   , NA                ,
  "A1B16"   , "Sport Gen 2"        , "Product Card"   , NA                ,
  "A2B1"    , "Amazon"             , "Brand"          , NA                ,
  "A2B2"    , "Apple"              , "Brand"          , NA                ,
  "A2B3"    , "Gentle Monster"     , "Brand"          , NA                ,
  "A2B4"    , "Google"             , "Brand"          , NA                ,
  "A2B5"    , "Meta"               , "Brand"          , NA                ,
  "A2B6"    , "Michael Kors"       , "Brand"          , NA                ,
  "A2B7"    , "Miu Miu"            , "Brand"          , NA                ,
  "A2B8"    , "Oakley"             , "Brand"          , NA                ,
  "A2B9"    , "Oliver Peoples"     , "Brand"          , NA                ,
  "A2B10"   , "Prada"              , "Brand"          , NA                ,
  "A2B11"   , "Ray-Ban"            , "Brand"          , NA                ,
  "A2B12"   , "Samsung"            , "Brand"          , NA                ,
  "A2B13"   , "Warby Parker"       , "Brand"          , NA                ,
  "A3B1"    , "$199"               , "Price"          ,                 1 ,
  "A3B2"    , "$249"               , "Price"          ,                 2 ,
  "A3B3"    , "$299"               , "Price"          ,                 3 ,
  "A3B4"    , "$349"               , "Price"          ,                 4 ,
  "A3B5"    , "$399"               , "Price"          ,                 5 ,
  "A3B6"    , "$449"               , "Price"          ,                 6 ,
  "A3B7"    , "$499"               , "Price"          ,                 7 ,
  "A3B8"    , "$549"               , "Price"          ,                 8 ,
  "A3B9"    , "$599"               , "Price"          ,                 9 ,
  "A3B10"   , "$649"               , "Price"          ,                10 ,
  "A3B11"   , "$699"               , "Price"          ,                11 ,
  "A3B12"   , "$749"               , "Price"          ,                12 ,
  "A3B13"   , "$799"               , "Price"          ,                13 ,
  "A3B14"   , "$849"               , "Price"          ,                14 ,
  "A3B15"   , "$899"               , "Price"          ,                15 ,
  "A3B16"   , "$949"               , "Price"          ,                16
)

df <- conjoint_df(df, crosswalk)

# Check out the conjoint_df
df

get_collections(df)

protected_cols(df)

## Define Products ----
rbm1 <- product(
  df,
  levels = c(
    'Ray-Ban',
    'Meta',
    'RBM 1',
    '$299'
  ),
  name = 'rbm1'
)

rbm2 <- product(
  df,
  levels = c(
    'Ray-Ban',
    'Meta',
    'RBM 2',
    '$399'
  ),
  name = 'rbm2'
)

hstn <- product(
  df,
  levels = c(
    'Oakley',
    'Meta',
    'HSTN',
    '$399'
  ),
  name = 'hstn'
)

omv <- product(
  df,
  levels = c(
    'Oakley',
    'Meta',
    'OMV',
    '$499'
  ),
  name = 'omv'
)

mrbd <- product(
  df,
  levels = c(
    'Meta',
    'Ray-Ban',
    'MRBD',
    '$799'
  ),
  name = 'mrbd'
)

modelo <- product(
  df,
  levels = c(
    'Meta',
    'Modelo',
    '$299'
  ),
  name = 'modelo'
)


luna <- product(
  df,
  levels = c(
    'Meta',
    'Ray-Ban',
    'Luna',
    '$249'
  ),
  name = 'luna'
)

daiquiri <- product(
  df,
  levels = c(
    'Meta',
    'Oakley',
    'Future Dai',
    '$449'
  ),
  name = 'daiquiri'
)

future_oakley <- product(
  df,
  levels = c(
    'Meta',
    'Oakley',
    'Future Oakley',
    '$449'
  ),
  name = 'future_oakley'
)

prada <- product(
  df,
  levels = c(
    'Meta',
    'Prada',
    'Competitor 1',
    '$699'
  ),
  name = 'prada'
)

google <- product(
  df,
  levels = c(
    'Google',
    'Competitor 2',
    '$399'
  ),
  name = 'google'
)

warby <- product(
  df,
  levels = c(
    'Warby Parker',
    'Competitor 2',
    '$399'
  ),
  name = 'warby'
)

rbm4 <- product(
  df,
  levels = c(
    'Ray-Ban',
    'Meta',
    'RBM 4',
    '$499'
  ),
  name = 'rbm4'
)

rbm2_optics <- product(
  df,
  levels = c(
    'Ray-Ban',
    'Meta',
    'RBM 2 Optics',
    '$449'
  ),
  name = 'rbm2_optics'
)

sport_gen_2 <- product(
  df,
  levels = c(
    'Ray-Ban',
    'Meta',
    'Sport Gen 2',
    '$499'
  ),
  name = 'sport_gen_2'
)

rectangular_oakley <- product(
  df,
  levels = c(
    'Oakley',
    'Meta',
    'Rectangular Oakley',
    '$449'
  ),
  name = 'rectangular_oakley'
)

hypernova_2 <- product(
  df,
  levels = c(
    'Meta',
    'Ray-Ban',
    'Hypernova 2',
    '$799'
  ),
  name = 'hypernova_2'
)

# Explore products a bit
hypernova_2


## Create competetive sets -----
current_products <- competitive_set(
  rbm1,
  rbm2,
  hstn,
  omv,
  mrbd,
  name = 'Current Products'
)

current_products

run_scenario(df, current_products)

# Create data structures for TURF ----
universe <- competitive_set(
  rbm1,
  rbm2,
  hstn,
  omv,
  mrbd,
  modelo,
  luna,
  daiquiri,
  future_oakley,
  prada,
  google,
  warby,
  rbm4,
  rbm2_optics,
  sport_gen_2,
  rectangular_oakley,
  hypernova_2
)

## Create utility df ----
compute_product_utility(df, hypernova_2)

utility_df <- universe@products |>
  map(\(x) compute_product_utility(df, x)) |>
  rlang::set_names(y2conjoint:::product_output_names(universe@products)) |>
  tibble::as_tibble() |>
  bind_cols(df[y2conjoint:::get_none(df)])

cols_bench <- universe@products |>
  y2conjoint:::product_output_names()

## Create activation matricies ----
row_max <- do.call(pmax, utility_df |> select(-NONE))
row_2nd <- apply(utility_df |> select(-NONE), 1, \(row) {
  sort(row, decreasing = TRUE)[2]
})
row_3rd <- apply(utility_df |> select(-NONE), 1, \(row) {
  sort(row, decreasing = TRUE)[3]
})

# Activated if in top N
top_1 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x == row_max & x != NONE)))

top_2 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_2nd & x != NONE)))

top_3 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_3rd & x != NONE)))

# Activated if in top N AND utility greater than None
top_1_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x == row_max & x > NONE)))

top_2_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_2nd & x > NONE)))

top_3_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_3rd & x > NONE)))


above_0 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= 0 & x != NONE)))

above_0_and_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= 0 & x > NONE)))

above_1_and_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= 1 & x > NONE)))

above_2_and_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= 2 & x > NONE)))

above_3_and_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= 3 & x > NONE)))

# Cap activation at the top N products by utility
cap_max_active <- function(active_df, utility_df, product_cols, max_n) {
  utility_mat <- as.matrix(utility_df[product_cols])
  active_mat <- as.matrix(active_df[product_cols])
  ranks <- t(apply(-utility_mat, 1, rank, ties.method = "first"))
  active_df[product_cols] <- active_mat * (ranks <= max_n)
  active_df
}

above_1_and_none_max_8 <- cap_max_active(
  above_1_and_none,
  utility_df,
  cols_bench,
  8
)

above_2_and_none_max_8 <- cap_max_active(
  above_2_and_none,
  utility_df,
  cols_bench,
  8
)

above_3_and_none_max_8 <- cap_max_active(
  above_3_and_none,
  utility_df,
  cols_bench,
  8
)


above_1_and_none_max_5 <- cap_max_active(
  above_1_and_none,
  utility_df,
  cols_bench,
  5
)

above_2_and_none_max_5 <- cap_max_active(
  above_2_and_none,
  utility_df,
  cols_bench,
  5
)

above_3_and_none_max_5 <- cap_max_active(
  above_3_and_none,
  utility_df,
  cols_bench,
  5
)


# Activated if a product's preference share vs. NONE (individually) beats
# NONE's share by at least `factor` times, i.e. exp(u) / (exp(u) + exp(NONE)) >=
# factor / (1 + factor). Solving for u gives a per-respondent threshold of
# NONE + log(factor), so NONE is exponentiated once and the resulting vector
# is compared against each product's utility.
beat_none_by_factor <- function(utility_df, factor) {
  exp_none <- exp(utility_df$NONE)
  threshold <- log(factor * exp_none)
  utility_df |>
    mutate(across(everything(), \(x) as.numeric(x >= threshold)))
}

beat_none_by_factor_and_threshold <- function(utility_df, factor, threshold_) {
  exp_none <- exp(utility_df$NONE)
  threshold <- log(factor * exp_none)
  utility_df |>
    mutate(across(everything(), \(x) {
      as.numeric(x >= threshold & x > threshold_)
    }))
}

beat_none_by_factor_and_max <- function(utility_df, factor, max) {
  exp_none <- exp(utility_df$NONE)
  threshold <- log(factor * exp_none)
  utility_df |>
    mutate(across(everything(), \(x) {
      as.numeric(x >= threshold)
    })) |>
    cap_max_active(utility_df, cols_bench, max)
}

beats_avg <- function(utility_df, num) {
  utility_df |>
    mutate(across(everything(), \(x) {
      as.numeric(x >= log(num))
    }))
}


# Activated if a product's preference share, when the choice set is just
# {utility-0 alternative, NONE, the product itself}, is at least
# percent_threshold, i.e. exp(u) / (exp(u) + exp(0) + exp(NONE)) >=
# percent_threshold. Solving for u gives a per-respondent threshold of
# log(percent_threshold * (1 + exp(NONE)) / (1 - percent_threshold)).
beats_comb_by <- function(utility_df, percent_threshold) {
  exp_none <- exp(utility_df$NONE)
  threshold <- log(percent_threshold * (1 + exp_none) / (1 - percent_threshold))
  utility_df |>
    mutate(across(everything(), \(x) as.numeric(x >= threshold)))
}

# Activated if a product's preference share, when the choice set is ALL real
# products plus NONE, is at least percent_threshold:
# exp(u_i) / (sum_j exp(u_j) + exp(NONE)) >= percent_threshold, where the sum
# is over every real product (including i itself). That row total already
# contains the tested product's own utility, so no algebra is needed to
# isolate it -- we just rearrange exp(u_i) >= p * total_exp directly into a
# per-row threshold on u_i.
all_pref_share_real <- function(utility_df, percent_threshold) {
  product_cols <- setdiff(names(utility_df), 'NONE')
  total_exp <- rowSums(exp(as.matrix(utility_df[product_cols]))) +
    exp(utility_df$NONE)
  threshold <- log(percent_threshold * total_exp)
  utility_df |>
    mutate(across(everything(), \(x) as.numeric(x >= threshold))) |>
    mutate(NONE = 0L)
}

# Activated if a product's preference share, when the choice set is the
# product itself against num_products "average" alternatives (each with
# utility 0, so exp(0) = 1) plus NONE, is at least percent_threshold:
# exp(u) / (exp(u) + num_products * 1 + exp(NONE)) >= percent_threshold.
# Here the denominator's num_products + exp(NONE) term is a fixed constant
# (doesn't already contain u), so u has to be solved for algebraically --
# same derivation as beats_comb_by, generalized from 1 average competitor to
# num_products of them.
all_pref_share_avg <- function(utility_df, percent_threshold) {
  num_products <- length(setdiff(names(utility_df), 'NONE'))
  exp_none <- exp(utility_df$NONE)
  threshold <- log(
    percent_threshold * (num_products + exp_none) / (1 - percent_threshold)
  )
  utility_df |>
    mutate(across(everything(), \(x) as.numeric(x >= threshold))) |>
    mutate(NONE = 0L)
}

# 2X (67%)
beat_none_by_2_factor <- beat_none_by_factor(utility_df, 2)

# 3X (75%)
beat_none_by_3_factor <- beat_none_by_factor(utility_df, 3)

# 4X (80%)
beat_none_by_4_factor <- beat_none_by_factor(utility_df, 4)

# 9X (90%)
beat_none_by_9_factor <- beat_none_by_factor(utility_df, 9)

beat_none_by_99_factor <- beat_none_by_factor(utility_df, 99)

beat_none_by_9_factor_above_0 <- beat_none_by_factor_and_threshold(
  utility_df,
  9,
  0
)

beat_none_by_99_factor_above_0 <- beat_none_by_factor_and_threshold(
  utility_df,
  99,
  0
)
beat_none_by_9_factor_max_8 <- beat_none_by_factor_and_max(utility_df, 9, 8)

beats_avg_by_2 <- beats_avg(utility_df, 2)
beats_avg_by_3 <- beats_avg(utility_df, 3)
beats_avg_by_4 <- beats_avg(utility_df, 4)
beats_avg_by_9 <- beats_avg(utility_df, 9)
beats_avg_by_20 <- beats_avg(utility_df, 20)
beats_avg_by_99 <- beats_avg(utility_df, 99)

beats_comb_50 <- beats_comb_by(utility_df, 0.50)
beats_comb_75 <- beats_comb_by(utility_df, 0.75)
beats_comb_80 <- beats_comb_by(utility_df, 0.80)
beats_comb_90 <- beats_comb_by(utility_df, 0.90)

avg_pshare_15 <- all_pref_share_real(utility_df, 0.15)
avg_pshare_10 <- all_pref_share_real(utility_df, 0.1)
avg_pshare_07 <- all_pref_share_real(utility_df, 0.07)

avg_pshare_50a <- all_pref_share_avg(utility_df, 0.50)
avg_pshare_25a <- all_pref_share_avg(utility_df, 0.25)
avg_pshare_15a <- all_pref_share_avg(utility_df, 0.15)
avg_pshare_10a <- all_pref_share_avg(utility_df, 0.1)


## Look at the activation matricies -----

freq_am <- function(data, data_label = rlang::caller_arg(data)) {
  data |>
    freq(digits = 3) |>
    filter(value == 1) |>
    rename(!!data_label := result) |>
    arrange(desc(n)) |>
    select(variable, !!data_label)
}

# Percent of a product that is activated by threshold
list(
  freq_am(top_1),
  freq_am(top_2),
  freq_am(top_3),
  freq_am(top_1_none),
  freq_am(top_2_none),
  freq_am(top_3_none),
  freq_am(beat_none_by_2_factor),
  freq_am(beat_none_by_3_factor),
  freq_am(beat_none_by_4_factor),
  freq_am(beat_none_by_9_factor),
  freq_am(beat_none_by_9_factor_above_0),
  freq_am(beat_none_by_9_factor_max_8),
  freq_am(beat_none_by_99_factor),
  freq_am(beat_none_by_99_factor_above_0),
  freq_am(beats_avg_by_2),
  freq_am(beats_avg_by_3),
  freq_am(beats_avg_by_4),
  freq_am(beats_avg_by_9),
  freq_am(beats_avg_by_20),
  freq_am(beats_avg_by_99),
  freq_am(beats_comb_50),
  freq_am(beats_comb_75),
  freq_am(beats_comb_80),
  freq_am(beats_comb_90),
  freq_am(avg_pshare_15),
  freq_am(avg_pshare_10),
  freq_am(avg_pshare_07),
  freq_am(avg_pshare_50a),
  freq_am(avg_pshare_25a),
  freq_am(avg_pshare_15a),
  freq_am(avg_pshare_10a)

  # freq_am(above_0),
  # freq_am(above_0_and_none),
  # freq_am(above_1_and_none),
  # freq_am(above_2_and_none),
  # freq_am(above_3_and_none),
  # freq_am(above_1_and_none_max_5),
  # freq_am(above_2_and_none_max_5),
  # freq_am(above_3_and_none_max_5),
  # freq_am(above_1_and_none_max_8),
  # freq_am(above_2_and_none_max_8),
  # freq_am(above_3_and_none_max_8)
) |>
  reduce(left_join) |>
  mutate(across(-variable, \(x) x * 100)) |>
  view()

num_activations <- function(data, data_label = rlang::caller_arg(data)) {
  data |>
    mutate(sums = rowSums(across(everything()))) |>
    freq(sums, digits = 3) |>
    select(value, !!data_label := result)
}

# Distribution of number of activations (per respondent) by threshold
num_activations_dist <- list(
  num_activations(top_1),
  num_activations(top_2),
  num_activations(top_3),
  num_activations(top_1_none),
  num_activations(top_2_none),
  num_activations(top_3_none),
  num_activations(beat_none_by_2_factor),
  num_activations(beat_none_by_3_factor),
  num_activations(beat_none_by_4_factor),
  num_activations(beat_none_by_9_factor),
  num_activations(beat_none_by_9_factor_above_0),
  num_activations(beat_none_by_9_factor_max_8),
  num_activations(beat_none_by_99_factor),
  num_activations(beat_none_by_99_factor_above_0),
  num_activations(beats_avg_by_2),
  num_activations(beats_avg_by_3),
  num_activations(beats_avg_by_4),
  num_activations(beats_avg_by_9),
  num_activations(beats_avg_by_20),
  num_activations(beats_avg_by_99),
  num_activations(beats_comb_50),
  num_activations(beats_comb_75),
  num_activations(beats_comb_80),
  num_activations(beats_comb_90),
  num_activations(avg_pshare_15),
  num_activations(avg_pshare_10),
  num_activations(avg_pshare_07),
  num_activations(avg_pshare_50a),
  num_activations(avg_pshare_25a),
  num_activations(avg_pshare_15a),
  num_activations(avg_pshare_10a)

  # num_activations(above_0),
  # num_activations(above_0_and_none),
  # num_activations(above_1_and_none),
  # num_activations(above_2_and_none),
  # num_activations(above_3_and_none),
  # num_activations(above_1_and_none_max_5),
  # num_activations(above_2_and_none_max_5),
  # num_activations(above_3_and_none_max_5),
  # num_activations(above_1_and_none_max_8),
  # num_activations(above_2_and_none_max_8),
  # num_activations(above_3_and_none_max_8)
) |>
  reduce(full_join) |>
  mutate(value = as.integer(value)) |>
  arrange(value) |>
  mutate(across(-value, \(x) x * 100))

num_activations_average <- num_activations_dist |>
  summarise(across(-value, \(x) sum(value * x / 100, na.rm = TRUE))) |>
  mutate(value = 'Average', .before = 1)

num_activations_dist |>
  mutate(value = as.character(value)) |>
  bind_rows(num_activations_average) |>
  view()

# Total number of activations

tot_activations <- function(data, data_label = rlang::caller_arg(data)) {
  data |>
    sum() |>
    rlang::set_names({{ data_label }})
}


# Total activations (frequency) by threshold
list(
  tot_activations(top_1),
  tot_activations(top_2),
  tot_activations(top_3),
  tot_activations(top_1_none),
  tot_activations(top_2_none),
  tot_activations(top_3_none),
  tot_activations(beat_none_by_2_factor),
  tot_activations(beat_none_by_3_factor),
  tot_activations(beat_none_by_4_factor),
  tot_activations(beat_none_by_9_factor),
  tot_activations(beat_none_by_9_factor_above_0),
  tot_activations(beat_none_by_9_factor_max_8),
  tot_activations(beat_none_by_99_factor),
  tot_activations(beat_none_by_99_factor_above_0),
  tot_activations(beats_avg_by_2),
  tot_activations(beats_avg_by_3),
  tot_activations(beats_avg_by_4),
  tot_activations(beats_avg_by_9),
  tot_activations(beats_avg_by_20),
  tot_activations(beats_avg_by_99),
  tot_activations(beats_comb_50),
  tot_activations(beats_comb_75),
  tot_activations(beats_comb_80),
  tot_activations(beats_comb_90),
  tot_activations(avg_pshare_15),
  tot_activations(avg_pshare_10),
  tot_activations(avg_pshare_07),
  tot_activations(avg_pshare_50a),
  tot_activations(avg_pshare_25a),
  tot_activations(avg_pshare_15a),
  tot_activations(avg_pshare_10a)

  # tot_activations(above_0),
  # tot_activations(above_0_and_none),
  # tot_activations(above_1_and_none),
  # tot_activations(above_2_and_none),
  # tot_activations(above_3_and_none),
  # tot_activations(above_1_and_none_max_5),
  # tot_activations(above_2_and_none_max_5),
  # tot_activations(above_3_and_none_max_5),
  # tot_activations(above_1_and_none_max_8),
  # tot_activations(above_2_and_none_max_8),
  # tot_activations(above_3_and_none_max_8)
) |>
  list_c() |>
  as_tibble_row() |>
  pivot_longer(everything()) |>
  arrange(desc(value)) |>
  mutate(
    avg_per_respondent = value / 5006,
    avg_activations_overall = avg_per_respondent / 17
  ) |>
  print(n = Inf)


turf_reach_bounds <- function(k, avg_prob) {
  stopifnot(avg_prob >= 0, avg_prob <= 1)
  tibble(
    k = k,
    avg_prob = avg_prob,
    uncorrelated_reach = 1 - (1 - avg_prob)^k,
    max_reach = pmin(1, k * avg_prob)
  )
}

turf_reach_bounds(5, 0.656)


utility_df |>
  freq(stat = 'summary') |>
  select(product = variable, stat, value = result) |>
  pivot_wider(names_from = stat, values_from = value) |>
  arrange(desc(median))

df |>
  as_tibble() |>
  select(-ID) |>
  freq(stat = 'summary') |>
  select(product = variable, stat, value = result) |>
  pivot_wider(names_from = stat, values_from = value) |>
  arrange(desc(median)) |>
  print(n = Inf)

.Last.value |> _$q75 |> mean()

# turf() --------------------------------------------------------------------

### Run turf on all our activation matricies ----
top_1_results <- turf(top_1, cols_bench, 8, 2, 20, 20)
top_2_results <- turf(top_2, cols_bench, 8, 2, 20, 20)
top_3_results <- turf(top_3, cols_bench, 8, 2, 20, 20)
top_1_none_results <- turf(top_1_none, cols_bench, 8, 2, 20, 20)
top_2_none_results <- turf(top_2_none, cols_bench, 8, 2, 20, 20)
top_3_none_results <- turf(top_3_none, cols_bench, 8, 2, 20, 20)
above_0_results <- turf(above_0, cols_bench, 8, 2, 20, 20)
above_0_and_none_results <- turf(above_0_and_none, cols_bench, 8, 2, 20, 20)
above_1_and_none_results <- turf(above_1_and_none, cols_bench, 8, 2, 20, 20)
above_2_and_none_results <- turf(above_2_and_none, cols_bench, 8, 2, 20, 20)
above_3_and_none_results <- turf(above_3_and_none, cols_bench, 8, 2, 20, 20)
above_1_and_none_max_5_results <- turf(
  above_1_and_none_max_5,
  cols_bench,
  8,
  2,
  20,
  20
)
above_2_and_none_max_5_results <- turf(
  above_2_and_none_max_5,
  cols_bench,
  8,
  2,
  20,
  20
)
above_3_and_none_max_5_results <- turf(
  above_3_and_none_max_5,
  cols_bench,
  8,
  2,
  20,
  20
)
above_1_and_none_max_8_results <- turf(
  above_1_and_none_max_8,
  cols_bench,
  8,
  2,
  20,
  20
)
above_2_and_none_max_8_results <- turf(
  above_2_and_none_max_8,
  cols_bench,
  8,
  2,
  20,
  20
)
above_3_and_none_max_8_results <- turf(
  above_3_and_none_max_8,
  cols_bench,
  8,
  2,
  20,
  20
)

results <- bind_rows(
  lst(
    top_1_results,
    top_2_results,
    top_3_results,
    top_1_none_results,
    top_2_none_results,
    top_3_none_results,
    above_0_results,
    above_0_and_none_results,
    above_1_and_none_results,
    above_2_and_none_results,
    above_3_and_none_results,
    above_1_and_none_max_5_results,
    above_2_and_none_max_5_results,
    above_3_and_none_max_5_results,
    above_1_and_none_max_8_results,
    above_2_and_none_max_8_results,
    above_3_and_none_max_8_results
  ),
  .id = 'dataset'
)

### Diagnostics and comparisons ----

# Total Reach
results |>
  select(dataset, rank, total_reach) |>
  pivot_wider(names_from = dataset, values_from = total_reach)


# Total Frequency
results |>
  select(dataset, rank, total_frequency) |>
  pivot_wider(names_from = dataset, values_from = total_frequency)

ordering <- top_1 |>
  freq() |>
  filter(value == 1) |>
  arrange(desc(n)) |>
  pull(variable)

top_ranked_products <- results |>
  mutate(products = map(products, ~ .x[order(match(.x, ordering))])) |>
  unnest_wider(products, '_') |>
  filter(rank == 1)

top_ranked_products |> view()

top_ranked_products |>
  select(stem('products')) |>
  pivot_longer(everything()) |>
  freq(value, digits = 3) |>
  arrange(desc(n)) |>
  mutate(result = result * 800, of = 17L) |>
  select(product = label, found = n, of, result)


# Old stuff -----
result <- bench::mark(
  split_4 = turf(top_1, cols_bench, 8, 4, 20, 20),
  split_3 = turf(top_1, cols_bench, 8, 3, 20, 20),
  split_2 = turf(top_1, cols_bench, 8, 2, 20, 20),
  full = turf(top_1, cols_bench, 8, 8, 20, 20),
  iterations = 50,
  check = FALSE
)

split_4 <- turf(top_1, cols_bench, 8, 4, 20, 20)
split_3 <- turf(top_1, cols_bench, 8, 3, 20, 20)
split_2 <- turf(top_1, cols_bench, 8, 2, 20, 20)
split_1 <- turf(top_1, cols_bench, 8, 1, 20, 20)
full <- turf(top_1, cols_bench, 8, 8, 20, 20)

full_results <- bind_rows(full, split_4, split_3, split_2, split_1) |>
  mutate(
    run = c(
      rep(8, 20),
      rep(4, 20),
      rep(3, 20),
      rep(2, 20),
      rep(1, 10)
    ),
    .before = everything()
  )

full_results |>
  select(run, rank, total_reach) |>
  pivot_wider(names_from = run, values_from = total_reach)


split_6_3_none_swaps <- turf(top_3_none, cols_bench, 8, 6, 20, 20) # 13234
split_5_3_none_swaps <- turf(top_3_none, cols_bench, 8, 5, 20, 20) # 7197
split_4_3_none_swaps <- turf(top_3_none, cols_bench, 8, 4, 20, 20) # 3974
split_3_3_none_swaps <- turf(top_3_none, cols_bench, 8, 3, 20, 20) # 2766
split_2_3_none_swaps <- turf(top_3_none, cols_bench, 8, 2, 20, 20) # 2580
split_1_3_none_swaps <- turf(top_3_none, cols_bench, 4, 1, 20, 20) # 2999
full_3_none_swaps <- turf(top_3_none, cols_bench, 4, 8, 20, 20) # 24310

split_6_3_none <- turf(top_3_none, cols_bench, 8, 6, 20, 20, use_swaps = FALSE) # 12431
split_5_3_none <- turf(top_3_none, cols_bench, 8, 5, 20, 20, use_swaps = FALSE) # 6408
split_4_3_none <- turf(top_3_none, cols_bench, 8, 4, 20, 20, use_swaps = FALSE) # 3095
split_3_3_none <- turf(top_3_none, cols_bench, 8, 3, 20, 20, use_swaps = FALSE) # 1099
split_2_3_none <- turf(top_3_none, cols_bench, 8, 2, 20, 20, use_swaps = FALSE) # 374
split_1_3_none <- turf(top_3_none, cols_bench, 8, 1, 20, 20, use_swaps = FALSE) # 142
full_3_none <- turf(top_3_none, cols_bench, 8, 8, 20, 20, use_swaps = FALSE) # 24310


full_results <- bind_rows(
  full_3_none,
  split_6_3_none,
  split_6_3_none_swaps,
  split_5_3_none,
  split_5_3_none_swaps,
  split_4_3_none,
  split_4_3_none_swaps,
  split_3_3_none,
  split_3_3_none_swaps,
  split_2_3_none,
  split_2_3_none_swaps,
  split_1_3_none,
  split_1_3_none_swaps
) |>
  mutate(
    run = c(
      rep(8, 20),
      rep(6, 40),
      rep(5, 40),
      rep(4, 40),
      rep(3, 40),
      rep(2, 40),
      rep(1, 40)
    ),
    swaps = c(
      rep(FALSE, 40),
      rep(TRUE, 20),
      rep(FALSE, 20),
      rep(TRUE, 20),
      rep(FALSE, 20),
      rep(TRUE, 20),
      rep(FALSE, 20),
      rep(TRUE, 20),
      rep(FALSE, 20),
      rep(TRUE, 20),
      rep(FALSE, 20),
      rep(TRUE, 20)
    ),
    .before = everything()
  )

full_results |>
  select(run, rank, swaps, total_reach) |>
  pivot_wider(names_from = c(run, swaps), values_from = total_reach)

full_results |>
  unnest_wider(products, '_') |>
  view()
