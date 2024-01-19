library(tidyverse)
source("P:/StudyData/NRT1/analysis/stressor_use/scripts/fun_stressor_use.R")

path_hw_unit_5 <- "P:/iaml/bookdown/homework/unit_5"

exclude_data <- function(ema, min_stressful_events = 2, min_ema = 8) {
  ema <- ema %>% 
    filter(n_stressful_events >= min_stressful_events) %>% 
    filter(n_ema >= min_ema) %>% 
    filter(subid != 22145) %>%   #placebo who took NRT
    select(-n_ema, -n_stressful_events)
  
  return(ema)
}

d <- read_csv(file.path(path_hw_unit_5, "prep", "ema.csv"),
              col_types = cols()) %>% 
  select_stressor_use_sample() %>%   # from fun_stressor_use.R
  filter(ema_start_date > quit_date) %>% 
  mutate(txt = str_sub(subid, 2, 2), #txt in second digit of subid
         txt = case_when(txt == "1" ~ "nrt",
                         txt == "2" ~ "placebo",
                         TRUE ~ NA_character_)) %>% 
  arrange(subid, ema_start_date) %>% 
  group_by(subid) %>% 
  mutate(next_cigs = lead(cigs, 1),
         prior_cigs = cigs,
         lag = as.numeric(difftime(lead(ema_start_date, 1), ema_start_date, 
                                   units = "hours")),
         time_since_quit = as.numeric(difftime(lead(ema_start_date, 1),
                                               quit_date,
                                               units = "days"))) %>% 
  filter(!(is.na(next_cigs))) %>% 
  mutate(n_ema = n(),
         n_stressful_events = sum(stressful_event > 0)) %>% 
  ungroup() %>% 
  select(-cigs, -quit_date, -ema_start_date, -patch, -lozenges) %>% 
  rename(cigs = next_cigs) %>% 
  mutate(across(contains("cigs"), ~ if_else(.x > 0, 1, 0))) %>% 
  exclude_data() %>% 
  relocate(subid, cigs) %>% 
  mutate(cigs = if_else(cigs == 0, "no", "yes")) %>% 
  glimpse()

write_csv(d, file.path(path_hw_unit_5, "smoking_ema.csv"))
