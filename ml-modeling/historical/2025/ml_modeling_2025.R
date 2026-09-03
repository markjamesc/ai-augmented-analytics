# Load libraries
library(tidymodels)
library(tidyverse)
library(openxlsx)

# Set seed for reproducibility
set.seed(123)

# Load data
data <- read_csv("marketing_sample_data.csv")

# Explore structure
glimpse(data)
table(data$Response)
colSums(is.na(data))

# Convert target to factor
data <- data %>%
  mutate(Response = as.factor(Response))

# Train/test split
split <- initial_split(data, prop = 0.8, strata = Response)
train <- training(split)
test <- testing(split)

# Preprocessing recipe
rec <- recipe(Response ~ ., data = train) %>%
  update_role(Customer_ID, new_role = "ID") %>%
  step_dummy(all_nominal_predictors()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_impute_mean(all_numeric_predictors())

# Logistic regression
log_model <- logistic_reg() %>%
  set_engine("glm") %>%
  set_mode("classification")

# Random forest
rf_model <- rand_forest(mtry = 6, trees = 500, min_n = 10) %>%
  set_engine("ranger", importance = "impurity") %>%
  set_mode("classification")

# Workflows
log_wf <- workflow() %>%
  add_model(log_model) %>%
  add_recipe(rec)

rf_wf <- workflow() %>%
  add_model(rf_model) %>%
  add_recipe(rec)

# Fit models
log_fit <- fit(log_wf, data = train)
rf_fit <- fit(rf_wf, data = train)

# Predict
log_preds <- predict(log_fit, test, type = "prob") %>%
  bind_cols(predict(log_fit, test)) %>%
  bind_cols(test %>% select(Response))

rf_preds <- predict(rf_fit, test, type = "prob") %>%
  bind_cols(predict(rf_fit, test)) %>%
  bind_cols(test %>% select(Response))

# Evaluation
metrics <- metric_set(accuracy, precision, recall, f_meas, roc_auc)

cat("???? Logistic Regression:\n")
print(metrics(log_preds,
              truth = Response,
              estimate = .pred_class,
              .pred_Yes))

cat("\n???? Random Forest:\n")
print(metrics(rf_preds,
              truth = Response,
              estimate = .pred_class,
              .pred_Yes))

# Confusion matrix (Random Forest)
cat("\n???? Confusion Matrix (Random Forest):\n")
print(conf_mat(rf_preds, truth = Response, estimate = .pred_class))

# Feature importance from random forest
rf_model_fit <- rf_fit %>% extract_fit_parsnip() %>% pluck("fit")

# Create top 10 importance table
var_imp <- as.data.frame(rf_model_fit$variable.importance) %>%
  rownames_to_column(var = "Feature") %>%
  rename(Importance = `rf_model_fit$variable.importance`) %>%
  arrange(desc(Importance)) %>%
  slice(1:10)

# Plot with ggplot2
ggplot(var_imp, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Important Features (Random Forest)",
       x = "Feature", y = "Importance") +
  theme_minimal()

# ---- Export to Excel using openxlsx ----

# Combine metrics
log_metrics <- metrics(log_preds,
                       truth = Response,
                       estimate = .pred_class,
                       .pred_Yes) %>%
  mutate(Model = "Logistic Regression")

rf_metrics <- metrics(rf_preds,
                      truth = Response,
                      estimate = .pred_class,
                      .pred_Yes) %>%
  mutate(Model = "Random Forest")

all_metrics <- bind_rows(log_metrics, rf_metrics)

# Get confusion matrix table
rf_conf <- conf_mat(rf_preds, truth = Response, estimate = .pred_class)
rf_conf_table <- as_tibble(rf_conf$table)

# Create workbook
wb <- createWorkbook()

# Add sheets
addWorksheet(wb, "Evaluation_Metrics")
addWorksheet(wb, "Confusion_Matrix")
addWorksheet(wb, "Feature_Importance")

# Write data
writeData(wb, "Evaluation_Metrics", all_metrics, withFilter = TRUE)
writeData(wb, "Confusion_Matrix", rf_conf_table, withFilter = TRUE)
writeData(wb, "Feature_Importance", var_imp, withFilter = TRUE)

# Formatting: bold headers
headerStyle <- createStyle(textDecoration = "bold")
addStyle(wb, "Evaluation_Metrics", headerStyle, rows = 1, cols = 1:ncol(all_metrics), gridExpand = TRUE)
addStyle(wb, "Confusion_Matrix", headerStyle, rows = 1, cols = 1:ncol(rf_conf_table), gridExpand = TRUE)
addStyle(wb, "Feature_Importance", headerStyle, rows = 1, cols = 1:ncol(var_imp), gridExpand = TRUE)

# Save workbook
saveWorkbook(wb, "ml_model_output.xlsx", overwrite = TRUE)


