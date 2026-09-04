# AI-Augmented Marketing Report Generator

An R workflow that summarizes a sample marketing dataset, sends the resulting evidence table to a configurable OpenAI model, and publishes the data plus three grounded narrative sections to Excel.

> **Output status:** The committed Excel workbook and archived script are the original May 2025 implementation. The current R script contains September 2026 corrections. Both versions are retained so the development is directly inspectable.

## Version history

| Artifact | Role |
|---|---|
| [Original 2025 script](historical/2025/generate_report_2025.R) | Historical implementation that produced the committed workbook |
| [Original 2025 workbook](gpt_marketing_report.xlsx) | Preserved output from the earlier workflow |
| [Revised script](generate_report.R) | Current corrected implementation; no replacement workbook is committed |

### What changed in the revised script

- Every model request receives the computed evidence table.
- Cross-sectional differences are no longer mislabeled as temporal trends.
- Recommendations must name supporting evidence and uncertainty.
- The model is configurable through `OPENAI_MODEL` rather than silently fixed.
- Missing API keys, HTTP failures, and malformed responses fail explicitly.

## Outputs

- Raw data
- Region-by-channel summary table
- Executive summary
- Cross-sectional performance-pattern analysis
- Evidence-constrained recommendations

Every model request receives the same computed summary table. The prompts instruct the model to distinguish observed facts from interpretation and avoid inventing unsupported causes.

## Stack

- R
- tidyverse
- httr and jsonlite
- glue
- openxlsx
- OpenAI Chat Completions API

## Run locally

Install the packages:

```r
install.packages(c("tidyverse", "openxlsx", "httr", "jsonlite", "glue"))
```

Set environment variables outside the script:

```r
Sys.setenv(OPENAI_API_KEY = "your-key")
Sys.setenv(OPENAI_MODEL = "your-supported-model")
```

`OPENAI_MODEL` is optional; the script provides a default that can be replaced without editing the analysis.

Run from this directory:

```r
source("generate_report.R")
```

## Files

| File | Purpose |
|---|---|
| [`generate_report.R`](generate_report.R) | Computes the evidence table, calls the model, and builds the workbook |
| [`marketing_sample_data.csv`](marketing_sample_data.csv) | Sample marketing observations |
| [`gpt_marketing_report.xlsx`](gpt_marketing_report.xlsx) | Example generated workbook |

## Limitations

- The analysis is cross-sectional; it does not establish temporal trends or causal effects.
- Model-generated interpretations require human review.
- Running the script sends the computed summary table to the configured API model and may incur usage charges.
- The committed workbook may have been produced with an earlier model configuration; rerunning creates the current output.

