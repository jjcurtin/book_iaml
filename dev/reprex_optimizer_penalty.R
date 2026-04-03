library(tidyverse)
library(tidymodels)

mnist <- keras::dataset_mnist()

set.seed(1234567)
d_in <- keras::array_reshape(mnist$train$x, c(nrow(mnist$train$x), 784))
colnames(d_in) <- str_c("v", 1:784)
d_in <- d_in |>
  as_tibble() |>
  mutate(label = factor(mnist$train$y), .before = 1) |>
  slice_sample(n = 10000)

rec <- recipe(label ~ ., data = d_in) |>
  step_zv(all_predictors()) |>
  step_normalize(all_predictors())

grid_penalty <- tibble(penalty = c(0, 0.001, 0.1))

set.seed(1234567)
torch::torch_manual_seed(1234567)
splits <- vfold_cv(d_in, v = 3)


# default (LBFGS)

set.seed(1234567)
torch::torch_manual_seed(1234567)
fits_lbfgs <- mlp(penalty = tune(),
                  hidden_units = 20,
                  epochs = 30) |>
  set_mode("classification") |>
  set_engine("brulee", validation = 0) |>
  tune_grid(preprocessor = rec,
            grid = grid_penalty,
            resamples = splits,
            metrics = metric_set(accuracy))

collect_metrics(fits_lbfgs)

# ADAMw

set.seed(1234567)
torch::torch_manual_seed(1234567)
fits_adamw <- mlp(penalty = tune(),
                  hidden_units = 20,
                  epochs = 30,
                  learn_rate = 0.001) |>
  set_mode("classification") |>
  set_engine("brulee",
             optimizer = "ADAMw",
             batch_size = 256,
             validation = 0) |>
  tune_grid(preprocessor = rec,
            grid = grid_penalty,
            resamples = splits,
            metrics = metric_set(accuracy))

collect_metrics(fits_adamw)
