profvis(apply_get_activations(am_matrix, many_cols), interval = 0.005)

profvis(
  turf(
    am,
    colnames(am),
    num_products = 5,
    batch_size = 1,
    keep_n_at_batch = 15,
    num_return = 5,
    show_combinations = FALSE
  ),
  interval = 0.005
)
