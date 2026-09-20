# AI-Augmented Analytics Portfolio

This repository contains three compact R projects demonstrating dashboarding, AI-assisted reporting, and interpretable classification. It is an earlier implementation portfolio and complements the newer decision-first case studies linked below.

> **Historical portfolio note:** This repository preserves the original May 2025 scripts and Excel outputs as evidence of an earlier stage of my AI-augmented analytics work. The main R scripts were revised in September 2026 after later review exposed analytical and implementation weaknesses. Both versions are visible so the development can be inspected directly; newer repositories demonstrate my current methodology.

## Versioned development

| Project | Original 2025 implementation | Revised 2026 implementation |
|---|---|---|
| GPT Reporting | [Original script](gpt-reporting/historical/2025/generate_report_2025.R) · [Original workbook](gpt-reporting/gpt_marketing_report.xlsx) | [Revised script](gpt-reporting/generate_report.R) · evidence supplied to every model request, safer claims, configurable model, API error handling |
| ML Modeling | [Original script](ml-modeling/historical/2025/ml_modeling_2025.R) · [Original workbook](ml-modeling/ml_model_output.xlsx) | [Revised script](ml-modeling/ml_modeling.R) · explicit positive class, corrected metric semantics, stronger preprocessing and limitations |

The historical workbooks remain paired with the original scripts. Revised workbooks are intentionally not committed, because this repository documents the change in method rather than replacing its historical evidence.

## Projects

| Project | Purpose | Stack | Evidence |
|---|---|---|---|
| [System Performance Dashboard](dashboard/) | Explore regional reliability, defect-rate, and downtime KPIs | R, Shiny, tidyverse, ggplot2, DT | Runnable app, sample data, screenshots |
| [Marketing Report Generator](gpt-reporting/) | Produce a structured Excel report with data-grounded AI narratives | R, OpenAI API, dplyr, openxlsx | Script, sample data, generated workbook |
| [Customer Response Classifier](ml-modeling/) | Compare logistic regression and random forest on a held-out test set | R, tidymodels, ranger, yardstick | Script, sample data, evaluation workbook |

## Skills demonstrated

- Reproducible data preparation in R
- Interactive Shiny dashboards
- Structured Excel publication
- API-based narrative generation
- Classification workflows with held-out evaluation
- Transparent limitations and reusable sample data

## Important scope note

These are focused demonstrations rather than production systems. The modeling project is a baseline comparison without hyperparameter tuning or cross-validation. The AI-reporting project requires a valid API key and sends summarized sample data to the configured model.

## Current portfolio work

- [FulfillIQ 2.0 — completed independent SQL/R validation case study](https://github.com/markjamesc/fulfilliq-2.0)
- [AI-Augmented Bitcoin Proxy Analysis](https://github.com/markjamesc/ai-augmented-bitcoin-proxy-analysis)
- [Five-Stage AI-Augmented Analyst Workflow](https://github.com/markjamesc/ai-augmented-analyst-workflow)
- [R Workflow Engine](https://github.com/markjamesc/ai-augmented-analyst-workflow/blob/main/docs/ENGINE.md)

## Contact

- [LinkedIn](https://www.linkedin.com/in/mark-ciganovic/)
- [GitHub](https://github.com/markjamesc/)

