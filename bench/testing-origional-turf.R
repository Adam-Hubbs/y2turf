library(tidyverse)
library(y2clerk)
library(haven)
library(labelled)


# Setup -------------------------------------------------------------------

PROJECT_PATH <- '~/Y2 Analytics Dropbox/Y2 Analytics Team Folder/Active Projects_LC/Meta/Wearables/Meta Wearables Pricing Study - Max'
DATA_PATH <- str_c(PROJECT_PATH, "/Data/Intn'l Weighted Data/")

list.files(DATA_PATH)

readdata <- function(responses) {
  read_sav(str_c(DATA_PATH, responses, ' Weighted Data.sav'))
}

responses_australia <- readdata("Australia")
responses_brazil <- readdata("Brazil")
responses_can <- readdata("Canada")
responses_france <- readdata("France")
responses_germ <- readdata("Germany")
responses_india <- readdata("India")
responses_italy <- readdata("Italy")
responses_mx <- readdata("Mexico")
responses_spain <- readdata("Spain")
responses_uk <- readdata("UK")
responses_usa <- readdata("USA")

# Make binary -------------------------------------------------------------

makebin <- function(responses) {
  responses %>%
    select(uuid, starts_with('S_GLASSES_CONSIDER_X_'), weights) %>%
    mutate(across(
      starts_with('S_GLASSES'),
      ~ case_when(
        .x %in% c(1) ~ 1, # Change this line to change what counts as a TURF qualifying answer
        TRUE ~ 0
      )
    ))
}

responses_usa <- makebin(responses_usa)
responses_usa_backup <- responses_usa
# TURF Calculations ---------------------------------------------------

maketall <- function(responses) {
  responses_tall <-
    responses %>%
    select(-weights) %>%
    pivot_longer(cols = -c(uuid)) %>%
    mutate(
      image_num = str_remove_all(name, 'S_GLASSES_CONSIDER_X_'),
      image_num = as.numeric(image_num)
    )
}

tall_usa <- maketall(responses_usa)

# Check that we have 11 options

checktall <- function(responses) {
  responses %>%
    freqs(image_num)
}
#run for all countries
#checktall()

getweights <- function(responses) {
  responses %>%
    select(uuid, weights)
}


weights_usa <- getweights(responses_usa)
weights_usa <- weights_usa |> mutate(weights = 1)

# # The combn() function is used to generate combinations of options
combn(x = 11, m = 5, simplify = FALSE)


run_turf <- function(image_nums, responses_tall, weights) {
  image_num_label <- str_flatten(as.character(image_nums), collapse = "|")
  num_options <- length(image_nums)

  responses_tall %>%
    filter(image_num %in% image_nums) %>%
    group_by(uuid) %>%
    summarize(undup_reach = max(value), frequency = sum(value)) %>%
    ungroup() %>%
    left_join(weights, by = 'uuid') %>%
    mutate(weighted_frequency = frequency * weights) %>%
    summarize(
      undup_reach = weighted.mean(undup_reach, w = weights),
      weighted_frequency = sum(weighted_frequency)
    ) %>%
    mutate(num_options = num_options, tested_options = image_num_label) %>%
    select(num_options, tested_options, undup_reach, weighted_frequency)
}
combinations <- combn(x = 1:11, m = 2, simplify = FALSE)

# Check that one set works
rst <- map_dfr(
  combinations,
  ~ run_turf(.x, responses_tall = tall_usa, weights = weights_usa)
)

# Create function for all turf possibilities for a single value of m
run_all_turf_options <- function(m, responses_tall, weights) {
  combinations <- combn(x = 1:11, m = m, simplify = FALSE)
  map_dfr(combinations, ~ run_turf(.x, responses_tall, weights))
}

rst2 <- run_all_turf_options(2, tall_usa, weights_usa)

# Loop through all combinations for each possible set of products (1-11), takes about 10 seconds
run_all_turf_for_country <- function(responses_tall, weights) {
  1:11 %>%
    map(~ run_all_turf_options(.x, responses_tall, weights)) %>%
    list_rbind()
}

results_usa <- run_all_turf_for_country(tall_usa, weights_usa)
results_usa_origional <- results_usa |>
  filter(num_options == 6) |>
  arrange(desc(undup_reach))


# Comparison ---
responses_turf <- responses_usa_backup |>
  select(stem('S_GLASSES_CONSIDER_X'))

poss_products <- names(responses_turf)

# Batch size 3
results_usa_turf <- turf(
  responses_turf,
  poss_products,
  num_products = 6,
  batch_size = 3,
  keep_n_at_batch = 20,
  num_return = 1
)

# Full permutation
results_usa_turf_full <- turf(
  responses_turf,
  poss_products,
  num_products = 6,
  batch_size = 6,
  keep_n_at_batch = 20,
  num_return = 462
)

results_usa_turf_full <- results_usa_turf_full |>
  mutate(
    options = map_chr(
      products,
      ~ str_remove(.x, 'S_GLASSES_CONSIDER_X_') |>
        as.numeric() |>
        sort() |>
        str_flatten(collapse = '|')
    )
  ) |>
  select(options, total_reach)


# Compare
results_usa_origional |>
  mutate(undup_reach = undup_reach * 1000) |>
  select(options = tested_options, total_reach = undup_reach)

results_usa_turf_full
