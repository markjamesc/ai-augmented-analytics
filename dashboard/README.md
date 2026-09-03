# System Performance Dashboard

An interactive R Shiny dashboard for exploring system-performance KPIs by region and date range.

![KPI summary preview](screenshots/kpi_summary.png)

## Features

- Region and date-range filters
- Defect-rate, reliability, and downtime time series
- Filtered KPI summary table
- Searchable and sortable detailed data table
- Reusable sample dataset with 288 observations

## Stack

- R
- Shiny
- tidyverse and ggplot2
- DT

## Run locally

Install the packages:

```r
install.packages(c("shiny", "tidyverse", "DT"))
```

Start R from this directory and run:

```r
shiny::runApp("app.R")
```

## Additional previews

- [Full dashboard view](screenshots/dashboard_view.pdf)
- [North-region view](screenshots/dashboard_north.pdf)
- [West-region view](screenshots/dashboard_west.pdf)

## Files

| File | Purpose |
|---|---|
| [`app.R`](app.R) | Shiny user interface, server logic, filtering, and charts |
| [`sample_data.csv`](sample_data.csv) | Demonstration KPI data |
| [`screenshots/`](screenshots/) | Rendered examples |

## Limitation

This is a compact demonstration app using local sample data. It does not include authentication, a production database connection, automated deployment, or monitoring.

