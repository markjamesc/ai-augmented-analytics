# AI-Augmented Marketing Report Generator

An R workflow that summarizes a sample marketing dataset, sends the resulting evidence table to a configurable OpenAI model, and publishes the data plus three grounded narrative sections to Excel.

> **Output status:** The committed Excel workbook is the original May 2025 output and is retained as a historical artifact. The current R script contains later corrections and would produce a revised output if executed.

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

