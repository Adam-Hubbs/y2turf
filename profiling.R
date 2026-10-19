profvis(apply_get_activations(am_matrix, many_cols), interval = 0.005)

profvis(
  turf(
    am,
    colnames(am),
    num_products = 8,
    batch_size = 4,
    keep_n_at_batch = 15,
    num_return = 30,
    show_combinations = TRUE
  ),
  interval = 0.005
)
