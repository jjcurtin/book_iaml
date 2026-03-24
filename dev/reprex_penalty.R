# to allow for experimentation across training sample size and number of hidden units. 
n_train <- 10000
n_hidden <- 20

library(tidyverse) 
library(tidymodels)

mnist <- keras::dataset_mnist()  # get mnist data from keras

# train set
set.seed(1234567)
d_in <- keras::array_reshape(mnist$train$x, c(nrow(mnist$train$x), 784))
colnames(d_in) <- str_c("v", 1:784)
d_in <-  d_in |> 
  as_tibble() |>  
  mutate(label = factor(mnist$train$y), .before = 1) |> 
  slice_sample(n = n_train) # set training sample size based on n_train above

# test set
d_out <- keras::array_reshape(mnist$test$x, c(nrow(mnist$test$x), 784))
colnames(d_out) <- str_c("v", 1:784)
d_out <-  d_out |> 
  as_tibble() |>  
  mutate(label = factor(mnist$test$y), .before = 1) 

# prep/bake features for held-in/out sets
rec <- 
  recipe(label ~ ., data = d_in) |>
  step_zv(all_predictors()) |> 
  step_normalize(all_predictors())
rec_prep <- rec |> 
  prep(d_in)
feat_in <- rec_prep |> 
  bake(NULL)
feat_out <- rec_prep |> 
  bake(d_out)

# Fit and eval model with no penalty 
set.seed(1234567) # make sure seed is same for all three models
fit_0 <- mlp(penalty = 0,
             hidden_units = n_hidden,
             epochs = 30) |>   # to speed up training a bit
    set_mode("classification") |> 
    set_engine("brulee",
               validation = 0) |> # to prevent early stopping
    fit(label ~ ., data = feat_in)
fit_0 # print model summary
accuracy_vec(feat_out$label, predict(fit_0, feat_out)$.pred_class)

# very very small penalty
# different (worse) performance
set.seed(1234567) 
fit_00000001 <- mlp(penalty = .00000001,
                    hidden_units = n_hidden,
                    epochs = 30) |>   
    set_mode("classification") |> 
    set_engine("brulee",
               validation = 0) |> 
    fit(label ~ ., data = feat_in)
fit_00000001 
accuracy_vec(feat_out$label, predict(fit_00000001, feat_out)$.pred_class)

# large penalty
set.seed(1234567) 
fit_1 <- mlp(penalty = 1,
             hidden_units = n_hidden,
             epochs = 30) |>   
    set_mode("classification") |> 
    set_engine("brulee",
               validation = 0) |> 
    fit(label ~ ., data = feat_in)
fit_1 
accuracy_vec(feat_out$label, predict(fit_1, feat_out)$.pred_class)

set.seed(102030)
splits <- d_in |>
  vfold_cv(v = 3)

grid_penalty <- tibble(penalty = c(.00000000001, .000000001, .0000001, .00001, .001, .1))

fits <- mlp(penalty = tune(), 
            hidden_units = 20,
            epochs = 30) |>
  set_mode("classification") |> 
  set_engine("brulee", 
             validation = 0) |>  
  tune_grid(preprocessor = rec, 
            grid = grid_penalty,
            resamples = splits,
            metrics = metric_set(accuracy))

collect_metrics(fits)

