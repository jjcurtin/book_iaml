n_train  <- 10000
n_hidden <- 20

library(tidyverse)
library(tidymodels)

mnist <- keras::dataset_mnist()

# train set
set.seed(1234567)
d_in <- keras::array_reshape(mnist$train$x, c(nrow(mnist$train$x), 784))
colnames(d_in) <- str_c("v", 1:784)
d_in <- d_in |>
  as_tibble() |>
  mutate(label = factor(mnist$train$y), .before = 1) |>
  slice_sample(n = n_train)

# test set
d_out <- keras::array_reshape(mnist$test$x, c(nrow(mnist$test$x), 784))
colnames(d_out) <- str_c("v", 1:784)
d_out <- d_out |>
  as_tibble() |>
  mutate(label = factor(mnist$test$y), .before = 1)

# preprocessing
rec <- recipe(label ~ ., data = d_in) |>
  step_zv(all_predictors()) |>
  step_normalize(all_predictors())

rec_prep <- prep(rec, d_in)
feat_in  <- bake(rec_prep, NULL)
feat_out <- bake(rec_prep, d_out)

# penalty grid used throughout
grid_penalty <- tibble(penalty = c(0, 1e-11, 1e-9, 1e-7, 1e-5, 1e-3, 0.1))


# test 1: LBFGS (default optimizer) penalty grid
# Q: does varying penalty in tune_grid produce different CV estimates?
# A: you'd think, but it's completely flat. seems like LBFGS 
# ignores penalty entirely.


set.seed(1234567)
torch::torch_manual_seed(1234567)
splits_lbfgs <- vfold_cv(d_in, v = 3)
set.seed(1234567)
torch::torch_manual_seed(1234567)
fits_lbfgs <- mlp(penalty = tune(),
                  hidden_units = n_hidden,
                  epochs = 30) |>
  set_mode("classification") |>
  set_engine("brulee", validation = 0) |>
  tune_grid(preprocessor = rec,
            grid = grid_penalty,
            resamples = splits_lbfgs,
            metrics = metric_set(accuracy))

collect_metrics(fits_lbfgs)


# test 2: Is tune_grid itself the problem?
# Q: does tune_grid produce different estimates than manual fit+predict
# on identical folds? controls for preprocessing by using pre-baked feat_in.
# A: no difference, the CV gap was due to training-size only, not a tune_grid.

set.seed(1234567)
torch::torch_manual_seed(1234567)
splits_50 <- vfold_cv(feat_in, v = 2)

# Manual fit+predict on each fold
manual_acc <- map_dbl(splits_50$splits, function(split) {
  set.seed(1234567)
  torch::torch_manual_seed(1234567)
  test  <- assessment(split)
  preds <- mlp(penalty = 0, hidden_units = n_hidden, epochs = 30) |>
    set_mode("classification") |>
    set_engine("brulee", validation = 0) |>
    fit(label ~ ., data = analysis(split)) |>
    predict(test)
  accuracy_vec(truth = test$label, estimate = preds$.pred_class)
})
mean(manual_acc)

# tune_grid on same splits, no re-preprocessing
fits_50 <- mlp(penalty = tune(),
               hidden_units = n_hidden,
               epochs = 30) |>
  set_mode("classification") |>
  set_engine("brulee", validation = 0) |>
  tune_grid(preprocessor = label ~ .,
            grid = grid_penalty,
            resamples = splits_50,
            metrics = metric_set(accuracy))

collect_metrics(fits_50)


# test 3: Does LBFGS treat penalty=0 differently from penalty>0?
# Q: is the original discrepancy (0.9162 vs 0.9136) a real penalty effect?
# A: diff=0, it seems LBFGS ignores penalty entirely.

set.seed(1234567)
torch::torch_manual_seed(1234567)
preds_0 <- mlp(penalty = 0, hidden_units = n_hidden, epochs = 30) |>
  set_mode("classification") |>
  set_engine("brulee", validation = 0) |>
  fit(label ~ ., data = feat_in) |>
  predict(feat_out)
acc_0 <- accuracy_vec(truth = feat_out$label, estimate = preds_0$.pred_class)

set.seed(1234567)
torch::torch_manual_seed(1234567)
preds_tiny <- mlp(penalty = 1e-8, hidden_units = n_hidden, epochs = 30) |>
  set_mode("classification") |>
  set_engine("brulee", validation = 0) |>
  fit(label ~ ., data = feat_in) |>
  predict(feat_out)
acc_tiny <- accuracy_vec(truth = feat_out$label, estimate = preds_tiny$.pred_class)

tibble(acc_0, acc_tiny, diff = acc_0 - acc_tiny)

# test 4: ADAMw penalty grid
# Q: does penalty work correctly with a supported optimizer?
# (confirmed in brulee github source code)
# note: requires batch_size and learn_rate to be set explicitly for ADAMw.
# A: 0.1 penalty has clear large effect compared to null and extreme low
# penalties. 

set.seed(1234567)
torch::torch_manual_seed(1234567)
splits_adamw <- vfold_cv(d_in, v = 3)

set.seed(1234567)
torch::torch_manual_seed(1234567)
fits_adamw <- mlp(penalty = tune(),
                  hidden_units = n_hidden,
                  epochs = 30,
                  learn_rate = 0.001) |>
  set_mode("classification") |>
  set_engine("brulee",
             optimizer = "ADAMw",
             batch_size = 256,
             validation = 0) |>
  tune_grid(preprocessor = rec,
            grid = grid_penalty,
            resamples = splits_adamw,
            metrics = metric_set(accuracy))

collect_metrics(fits_adamw)
