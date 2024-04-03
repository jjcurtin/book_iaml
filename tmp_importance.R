This is a bit more complicated for classification models because we have to first make a wrapper around `predict()` so that it returns class probabilities rather than class label predictions, which is otherwise the default.  Then we have to use that wrapper inside of the `iml` `Predictor$new()` function.   

If you were calculating feature importance for a regression model, you would not need the wrapper function.

```{r predictor_function}
# only needed for classification models
predict_wrapper <- function(model, newdata) {
  predict(model, newdata, type = "prob") |>  # set type = "prob" for probabilities
    dplyr::select(yes = .pred_yes, no = .pred_no)
  
}

# make iml predictor function
predictor <- iml::Predictor$new(model = fit_full, 
                                data = x, 
                                y = y,
                                predict.fun = predict_wrapper)  
# No need to set predict.fun for regression models
```

We can now use this predictor function : `predictor` with various `iml` functions





This is a bit more complicated for classification models because we have to first make a wrapper around `predict()` so that it returns class probabilities rather than class label predictions, which is otherwise the default.  Then we have to use that wrapper inside of the `iml` `Predictor$new()` function.   

If you were calculating feature importance for a regression model, you would not need the wrapper function.

```{r predictor_function}
# only needed for classification models
predict_wrapper <- function(model, newdata) {
  predict(model, newdata, type = "prob") |>  # set type = "prob" for probabilities
    dplyr::select(yes = .pred_yes, no = .pred_no)
  
}

# make iml predictor function
predictor <- iml::Predictor$new(model = fit_full, 
                                data = x, 
                                y = y,
                                predict.fun = predict_wrapper)  
# No need to set predict.fun for regression models
```

We can now use this predictor function : `predictor` with various `iml` functions

