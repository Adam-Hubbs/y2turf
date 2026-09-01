# jarl-ignore-file internal_function: Development purposes only
# Setup -----------------------------------------------

## Packages ---------------------------------------------------------------
library(y2clerk)
library(tidyverse)
library(haven)
library(purrr)
library(labelled)
#pak::pak("y2analytics/y2conjoint@multi-competetive-sets")
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

# Create activation df
row_max <- do.call(pmax, utility_df)
row_2nd <- apply(utility_df, 1, \(row) sort(row, decreasing = TRUE)[2])
row_3rd <- apply(utility_df, 1, \(row) sort(row, decreasing = TRUE)[3])

# Activated if in top N
top_1 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x == row_max)))

top_2 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_2nd)))

top_3 <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_3rd)))

# Activated if in top N AND utility greater than None
top_1_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x == row_max & x >= NONE)))

top_2_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_2nd & x >= NONE)))

top_3_none <- utility_df |>
  mutate(across(everything(), \(x) as.numeric(x >= row_3rd & x >= NONE)))

# top_1 is the same, many differences in top_2 and top_3
waldo::compare(top_1, top_1_none)
waldo::compare(top_2, top_2_none, max_diffs = 1) # 740 differences
waldo::compare(top_3, top_3_none, max_diffs = 1) # 1092 differences


## turf() --------------------------------------------------------------------

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
