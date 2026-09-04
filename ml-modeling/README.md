# Customer Response Classifier

A compact R/tidymodels project comparing logistic regression with a random forest for predicting whether a customer responds to a marketing offer.

> **Output status:** The committed Excel workbook and archived script are the original May 2025 implementation. The current R script contains September 2026 corrections. Both versions are retained so the development is directly inspectable.

## Version history

| Artifact | Role |
|---|---|
| [Original 2025 script](historical/2025/ml_modeling_2025.R) | Historical implementation that produced the committed workbook |
| [Original 2025 workbook](ml_model_output.xlsx) | Preserved output from the earlier workflow |
| [Revised script](ml_modeling.R) | Later reviewed implementation; it has not been used to replace the historical workbook |

### What changed in the revised script

- `Yes` is explicitly defined as the positive response class.
- Precision, recall, F1, and ROC AUC use explicit event-level semantics.
- Missing numeric values are imputed before normalization.
- Unknown categorical values are handled before dummy encoding.
- Feature importance is labeled descriptive rather than causal.
- Production limitations are stated directly.

## Workflow

- Stratified 80/20 train-test split
- Training-only preprocessing recipe
- Missing-value handling, dummy encoding, zero-variance removal, and normalization
- Logistic-regression baseline
- Random-forest comparison
- Held-out accuracy, precision, recall, F1, ROC AUC, and confusion matrix
- Random-forest feature-importance table
- Excel publication of evaluation results

The positive class is explicitly defined as `Yes`, preventing event-level ambiguity in precision, recall, F1, and ROC AUC.

## Stack

- R
- tidymodels
- ranger
- yardstick
- tidyverse and ggplot2
- openxlsx

## Run locally

Install the packages:

```r
install.packages(c("tidymodels", "tidyverse", "openxlsx", "ranger"))
```

Run from this directory:

```r
source("ml_modeling.R")
```

## Files

| File | Purpose |
|---|---|
| [`marketing_sample_data.csv`](marketing_sample_data.csv) | Demonstration customer dataset |
| [`ml_modeling.R`](ml_modeling.R) | Preprocessing, model fitting, held-out evaluation, and export |
| [`ml_model_output.xlsx`](ml_model_output.xlsx) | Example evaluation workbook |

## Limitations

- This is a baseline demonstration, not a production model.
- Hyperparameters are fixed rather than tuned through cross-validation.
- Impurity-based random-forest importance can favor variables with more possible split points.
- The held-out test set is used once for comparison; operational deployment would require calibration, stability, fairness, and monitoring checks.

