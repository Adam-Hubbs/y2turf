# Define a test activation matrix

col_names <- c(
  'northwind',
  'southwind',
  'may',
  'flick',
  'toasty',
  'slimey',
  'slim',
  'heavy',
  'blue',
  'red',
  'green',
  'coi',
  'herring',
  'bengal',
  'plum',
  'pair',
  'cherry',
  'lime',
  'apple',
  'mango',
  'peach',
  'tomato',
  'lettuce',
  'zuccini',
  'cucumber',
  'pickle',
  'olive',
  'grape',
  'grapefruit',
  'lemon',
  'citrus',
  'pink',
  'neon',
  'shady',
  'wide',
  'papaya',
  'orange',
  'penne',
  'lasagna',
  'orzo',
  'fluff',
  'hairy',
  'bald',
  'nether',
  'seattle',
  'tokyo',
  'london',
  'madrid',
  'rome',
  'moscow',
  'liverpool',
  'manchester',
  'york'
)

am <- tibble::as_tibble(matrix(
  integer(),
  nrow = 1000L,
  ncol = length(col_names),
  dimnames = list(NULL, col_names)
))


am1 <- am |>
  dplyr::bind_rows(am, am, am, am) |>
  dplyr::mutate(
    dplyr::across(1:4, \(x) sample(c(0, 1), 5000, TRUE, c(0.75, 0.25))),
    dplyr::across(5:9, \(x) sample(c(0, 1), 5000, TRUE, c(0.78, 0.22))),
    dplyr::across(10:14, \(x) sample(c(0, 1), 5000, TRUE, c(0.8, 0.2))),
    dplyr::across(15:19, \(x) sample(c(0, 1), 5000, TRUE, c(0.85, 0.15))),
    dplyr::across(20:23, \(x) sample(c(0, 1), 5000, TRUE, c(0.89, 0.11))),
    dplyr::across(24:26, \(x) sample(c(0, 1), 5000, TRUE, c(0.93, 0.07))),
    dplyr::across(27:28, \(x) sample(c(0, 1), 5000, TRUE, c(0.94, 0.06))),
    dplyr::across(29:31, \(x) sample(c(0, 1), 5000, TRUE, c(0.91, 0.09))),
    dplyr::across(32:34, \(x) sample(c(0, 1), 5000, TRUE, c(0.92, 0.08))),
    dplyr::across(35:37, \(x) sample(c(0, 1), 5000, TRUE, c(0.93, 0.07))),
    dplyr::across(38:41, \(x) sample(c(0, 1), 5000, TRUE, c(0.94, 0.06))),
    dplyr::across(42:46, \(x) sample(c(0, 1), 5000, TRUE, c(0.95, 0.05))),
    dplyr::across(47:50, \(x) sample(c(0, 1), 5000, TRUE, c(0.96, 0.04))),
    dplyr::across(51:53, \(x) sample(c(0, 1), 5000, TRUE, c(0.97, 0.03)))
  )

am2 <- am |>
  dplyr::bind_rows(am, am, am) |>
  dplyr::mutate(
    dplyr::across(1:4, \(x) sample(c(0, 1), 4000, TRUE, c(0.85, 0.15))),
    dplyr::across(5:8, \(x) sample(c(0, 1), 4000, TRUE, c(0.88, 0.12))),
    dplyr::across(9:14, \(x) sample(c(0, 1), 4000, TRUE, c(0.87, 0.13))),
    dplyr::across(15:19, \(x) sample(c(0, 1), 4000, TRUE, c(0.89, 0.11))),
    dplyr::across(20:23, \(x) sample(c(0, 1), 4000, TRUE, c(0.9, 0.10))),
    dplyr::across(24:26, \(x) sample(c(0, 1), 4000, TRUE, c(0.92, 0.08))),
    dplyr::across(27:29, \(x) sample(c(0, 1), 4000, TRUE, c(0.95, 0.05))),
    dplyr::across(30:31, \(x) sample(c(0, 1), 4000, TRUE, c(0.6, 0.4))),
    dplyr::across(32:34, \(x) sample(c(0, 1), 4000, TRUE, c(0.8, 0.2))),
    dplyr::across(35:37, \(x) sample(c(0, 1), 4000, TRUE, c(0.9, 0.1))),
    dplyr::across(38:41, \(x) sample(c(0, 1), 4000, TRUE, c(0.91, 0.09))),
    dplyr::across(42:46, \(x) sample(c(0, 1), 4000, TRUE, c(0.93, 0.07))),
    dplyr::across(47:49, \(x) sample(c(0, 1), 4000, TRUE, c(0.94, 0.06))),
    dplyr::across(50:53, \(x) sample(c(0, 1), 4000, TRUE, c(0.92, 0.08)))
  )

am3 <- am |>
  dplyr::bind_rows(am, am) |>
  dplyr::mutate(
    dplyr::across(1:3, \(x) sample(c(0, 1), 3000, TRUE, c(0.71, 0.29))),
    dplyr::across(4:9, \(x) sample(c(0, 1), 3000, TRUE, c(0.66, 0.34))),
    dplyr::across(10:14, \(x) sample(c(0, 1), 3000, TRUE, c(0.69, 0.31))),
    dplyr::across(15:19, \(x) sample(c(0, 1), 3000, TRUE, c(0.7, 0.30))),
    dplyr::across(20:22, \(x) sample(c(0, 1), 3000, TRUE, c(0.68, 0.32))),
    dplyr::across(23:26, \(x) sample(c(0, 1), 3000, TRUE, c(0.86, 0.14))),
    dplyr::across(27:28, \(x) sample(c(0, 1), 3000, TRUE, c(0.72, 0.28))),
    dplyr::across(29:31, \(x) sample(c(0, 1), 3000, TRUE, c(0.89, 0.11))),
    dplyr::across(32:34, \(x) sample(c(0, 1), 3000, TRUE, c(0.98, 0.02))),
    dplyr::across(35:37, \(x) sample(c(0, 1), 3000, TRUE, c(0.97, 0.03))),
    dplyr::across(38:41, \(x) sample(c(0, 1), 3000, TRUE, c(0.7, 0.3))),
    dplyr::across(42:47, \(x) sample(c(0, 1), 3000, TRUE, c(0.96, 0.04))),
    dplyr::across(48:50, \(x) sample(c(0, 1), 3000, TRUE, c(0.95, 0.05))),
    dplyr::across(51:53, \(x) sample(c(0, 1), 3000, TRUE, c(0.69, 0.31)))
  )

am4 <- am |>
  dplyr::bind_rows(am) |>
  dplyr::mutate(
    dplyr::across(1:4, \(x) sample(c(0, 1), 2000, TRUE, c(0.87, 0.13))),
    dplyr::across(5:9, \(x) sample(c(0, 1), 2000, TRUE, c(0.83, 0.17))),
    dplyr::across(10:14, \(x) sample(c(0, 1), 2000, TRUE, c(0.76, 0.24))),
    dplyr::across(15:19, \(x) sample(c(0, 1), 2000, TRUE, c(0.82, 0.18))),
    dplyr::across(20:22, \(x) sample(c(0, 1), 2000, TRUE, c(0.89, 0.11))),
    dplyr::across(23:26, \(x) sample(c(0, 1), 2000, TRUE, c(0.88, 0.12))),
    dplyr::across(27:28, \(x) sample(c(0, 1), 2000, TRUE, c(0.82, 0.18))),
    dplyr::across(29:31, \(x) sample(c(0, 1), 2000, TRUE, c(0.78, 0.22))),
    dplyr::across(32:33, \(x) sample(c(0, 1), 2000, TRUE, c(0.8, 0.2))),
    dplyr::across(34:37, \(x) sample(c(0, 1), 2000, TRUE, c(0.9, 0.1))),
    dplyr::across(38:40, \(x) sample(c(0, 1), 2000, TRUE, c(0.79, 0.21))),
    dplyr::across(41:46, \(x) sample(c(0, 1), 2000, TRUE, c(0.77, 0.23))),
    dplyr::across(47:50, \(x) sample(c(0, 1), 2000, TRUE, c(0.6, 0.4))),
    dplyr::across(51:53, \(x) sample(c(0, 1), 2000, TRUE, c(0.72, 0.28)))
  )

am5 <- am |>
  dplyr::mutate(
    dplyr::across(1:4, \(x) sample(c(0, 1), 1000, TRUE, c(0.85, 0.15))),
    dplyr::across(5:9, \(x) sample(c(0, 1), 1000, TRUE, c(0.9, 10))),
    dplyr::across(10:14, \(x) sample(c(0, 1), 1000, TRUE, c(0.73, 0.27))),
    dplyr::across(15:20, \(x) sample(c(0, 1), 1000, TRUE, c(0.9, 0.1))),
    dplyr::across(21:23, \(x) sample(c(0, 1), 1000, TRUE, c(0.92, 0.08))),
    dplyr::across(24:26, \(x) sample(c(0, 1), 1000, TRUE, c(0.93, 0.07))),
    dplyr::across(27:29, \(x) sample(c(0, 1), 1000, TRUE, c(0.94, 0.06))),
    dplyr::across(30:32, \(x) sample(c(0, 1), 1000, TRUE, c(0.8, 0.2))),
    dplyr::across(33:34, \(x) sample(c(0, 1), 1000, TRUE, c(0.84, 0.16))),
    dplyr::across(35:38, \(x) sample(c(0, 1), 1000, TRUE, c(0.89, 0.11))),
    dplyr::across(39:41, \(x) sample(c(0, 1), 1000, TRUE, c(0.86, 0.14))),
    dplyr::across(42:46, \(x) sample(c(0, 1), 1000, TRUE, c(0.5, 0.5))),
    dplyr::across(47:50, \(x) sample(c(0, 1), 1000, TRUE, c(0.83, 0.17))),
    dplyr::across(51:53, \(x) sample(c(0, 1), 1000, TRUE, c(0.79, 0.21)))
  )

am <- dplyr::bind_rows(am1, am2, am3, am4, am5)

am <- am |>
  dplyr::mutate(
    dplyr::across(
      c(
        tidyselect::everything(),
        -2,
        -7,
        -12,
        -15,
        -16,
        -20,
        -22,
        -24,
        -28,
        -32,
        -33,
        -35,
        -38,
        -39,
        -41,
        -42,
        -46,
        -48,
        -50,
        -52
      ),
      \(x) {
        dplyr::if_else(
          sample(c(TRUE, FALSE), 15000L, TRUE, c(0.05, 0.95)),
          0L,
          x
        )
      }
    ),
    across(
      c(
        everything(),
        -1,
        -4,
        -5,
        -7,
        -8,
        -13,
        -14,
        -17,
        -22,
        -26,
        -28,
        -29,
        -31,
        -36,
        -41,
        -43,
        -50
      ),
      \(y) {
        dplyr::if_else(
          sample(c(TRUE, FALSE), 15000L, TRUE, c(0.1, 0.8)),
          1L,
          y
        )
      }
    )
  )


pick_n <- function(df, n) {
  for (i in seq_len(nrow(df))) {
    ones <- which(df[i, ] == 1)

    if (length(ones) > n) {
      keep <- sample(ones, n)
      df[i, ] <- 0
      df[i, keep] <- 1
    }
  }
  df
}

am <- am |>
  pick_n(4)

am |>
  dplyr::mutate(total = rowSums(dplyr::across(tidyselect::everything()))) |>
  y2clerk::freq(total) |>
  dplyr::arrange(desc(n)) |>
  dplyr::select(variable, n, result)

am |>
  dplyr::mutate(total = rowSums(dplyr::across(tidyselect::everything()))) |>
  y2clerk::freq(-total) |>
  dplyr::filter(value == 1) |>
  dplyr::arrange(desc(n)) |>
  dplyr::select(variable, result)


usethis::use_data(am, overwrite = TRUE)
