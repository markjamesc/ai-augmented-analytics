library(tidymodels)
library(tidyverse)
library(openxlsx)

set.seed(123)

# ---- Load data ---------------------------------------------------------------

data <- read_csv("marketing_sample_data.csv", show_col_types = FALSE) %>%
  mutate(Response = factor(Response, levels = c("No", "Yes")))

if (any(is.na(data$Response))) {
  stop("Response contains values outside the expected No/Yes classes.", call. = FALSE)
}

# ---- Split and preprocess ----------------------------------------------------

split <- initial_split(data, prop = 0.8, strata = Response)
train <- training(split)
test <- testing(split)

rec <- recipe(Response ~ ., data = train) %>%
  update_role(Customer_ID, new_role = "ID") %>%
  step_unknown(all_nominal_predictors()) %>%
  step_impute_median(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_numeric_predictors())

# ---- Models ------------------------------------------------------------------

log_model <- logistic_reg() %>%
  set_engine("glm") %>%
  set_mode("classification")

rf_model <- rand_forest(mtry = 6, trees = 500, min_n = 10) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("classification")

log_wf <- workflow() %>%
  add_model(log_model) %>%
  add_recipe(rec)

rf_wf <- workflow() %>%
  add_model(rf_model) %>%
  add_recipe(rec)

log_fit <- fit(log_wf, data = train)
rf_fit <- fit(rf_wf, data = train)

# ---- Held-out predictions ----------------------------------------------------

predict_with_truth <- function(fitted_workflow, test_data) {
  predict(fitted_workflow, test_data, type = "prob") %>%
    bind_cols(predict(fitted_workflow, test_data, type = "class")) %>%
    bind_cols(test_data %>% select(Response))
}

log_preds <- predict_with_truth(log_fit, test)
rf_preds <- predict_with_truth(rf_fit, test)

evaluate_predictions <- function(predictions, model_name) {
  bind_rows(
    accuracy(predictions, truth = Response, estimate = .pred_class),
    precision(
      predictions,
      truth = Response,
      estimate = .pred_class,
      event_level = "second"
    ),
    recall(
      predictions,
      truth = Response,
      estimate = .pred_class,
      event_level = "second"
    ),
    f_meas(
      predictions,
      truth = Response,
      estimate = .pred_class,
      event_level = "second"
    ),
    roc_auc(
      predictions,
      truth = Response,
      .pred_Yes,
      event_level = "second"
    )
  ) %>%
    mutate(Model = model_name, .before = 1)
}

all_metrics <- bind_rows(
  evaluate_predictions(log_preds, "Logistic Regression"),
  evaluate_predictions(rf_preds, "Random Forest")
)

rf_conf <- conf_mat(rf_preds, truth = Response, estimate = .pred_class)
rf_conf_table <- as_tibble(rf_conf$table)

# ---- Random-forest importance ------------------------------------------------

rf_model_fit <- rf_fit %>%
  extract_fit_parsnip() %>%
  pluck("fit")

var_imp <- enframe(
  rf_model_fit$variable.importance,
  name = "Feature",
  value = "Importance"
) %>%
  arrange(desc(Importance)) %>%
  slice_head(n = 10)

importance_plot <- ggplot(
  var_imp,
  aes(x = reorder(Feature, Importance), y = Importance)
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Random-Forest Features",
    subtitle = "Impurity importance; interpret as descriptive, not causal",
    x = NULL,
    y = "Importance"
  ) +
  theme_minimal()

print(all_metrics)
print(rf_conf)
print(importance_plot)

# ---- Excel output ------------------------------------------------------------

wb <- createWorkbook()
addWorksheet(wb, "Evaluation_Metrics")
addWorksheet(wb, "Confusion_Matrix")
addWorksheet(wb, "Feature_Importance")

writeData(wb, "Evaluation_Metrics", all_metrics, withFilter = TRUE)
writeData(wb, "Confusion_Matrix", rf_conf_table, withFilter = TRUE)
writeData(wb, "Feature_Importance", var_imp, withFilter = TRUE)

header_style <- createStyle(textDecoration = "bold")
addStyle(
  wb,
  "Evaluation_Metrics",
  header_style,
  rows = 1,
  cols = seq_len(ncol(all_metrics)),
  gridExpand = TRUE
)
addStyle(
  wb,
  "Confusion_Matrix",
  header_style,
  rows = 1,
  cols = seq_len(ncol(rf_conf_table)),
  gridExpand = TRUE
)
addStyle(
  wb,
  "Feature_Importance",
  header_style,
  rows = 1,
  cols = seq_len(ncol(var_imp)),
  gridExpand = TRUE
)

freezePane(wb, "Evaluation_Metrics", firstRow = TRUE)
freezePane(wb, "Confusion_Matrix", firstRow = TRUE)
freezePane(wb, "Feature_Importance", firstRow = TRUE)

saveWorkbook(wb, "ml_model_output.xlsx", overwrite = TRUE)
message("Model evaluation written to ml_model_output.xlsx")

