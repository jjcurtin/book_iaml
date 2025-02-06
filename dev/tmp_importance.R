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




## Detecting Interactions

We can explore the magnitude of interactions among our features as well to better understand our model.  

We can estimate the magnitude of the interaction using the H-statistic, developed by [Friedman and Popescu (2008)](https://arxiv.org/abs/0811.1679).

The H-statistic quantifies proportion of total variance in the predictions that is explained by the interactions.

We can calculate that for total variance across all the (two-way) interactions a feature can have with other features or we can look all the specific two-way interactions individually for a target feature.  Lets look at both.

```{r}
# int_all <-xfun::cache_rds({
#   
#   iml::Interaction$new(predictor) 
#   
# },
# rerun = FALSE,
# dir = "cache/",
# file = "u9-all_interactions")
```

Here is the default plot for each features total interactions across all other features
```{r}
# int_all |>  plot
```

And a clearer plot
```{r}
# int_all$results |> 
#   dplyr::filter(.class == "yes") |> 
#   dplyr::arrange(abs(.interaction)) |> 
#   dplyr::mutate(.feature = factor(.feature),
#          .feature = forcats::fct_inorder(.feature)) |> 
#   ggplot() +
#   geom_col(mapping = aes(x = .feature, y = .interaction))  +
#   ylab("H-stasitic") +
#   coord_flip()
```

And here are all the interactions with the `exer_max_hr` feature. 
```{r specific_interactions}
# int_one <- iml::Interaction$new(predictor, feature = "exer_max_hr") 
```

```{r}
# int_one$results |>   
#   dplyr::filter(.class == "yes") |>
#   dplyr::arrange(abs(.interaction)) |> 
#   dplyr::mutate(.feature = factor(.feature),
#          .feature = forcats::fct_inorder(.feature)) |> 
#   ggplot() +
#   geom_col(mapping = aes(x = .feature, y = .interaction))  +
#   ylab("H-stasitic") +
#   coord_flip()
```


Cleveland plots are sometimes considered easier to view than bar plots and could have been used for many of the above graphs.  Here is an example of a Cleveland plot for the H-statistic

```{r}
# int_one$results |>   
#   filter(.class == "yes") |>
#   dplyr::arrange(abs(.interaction)) |> 
#   dplyr::mutate(.feature = factor(.feature),
#          .feature = forcats::fct_inorder(.feature)) |> 
#   ggplot(mapping = aes(x = .feature, y = .interaction)) +
#   geom_point(size = 2, color = "red") +
#   geom_segment(aes(x = .feature, y = .interaction, xend = .feature), yend = 0, colour = "grey50")  +
#   ylab("H-stasitic") +
#   coord_flip()
```

