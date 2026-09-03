library(tidyverse)
library(openxlsx)
library(httr)
library(jsonlite)
library(glue)

# ---- Configuration -----------------------------------------------------------

api_key <- Sys.getenv("OPENAI_API_KEY")
model_name <- Sys.getenv("OPENAI_MODEL", unset = "gpt-4.1-mini")

if (!nzchar(api_key)) {
  stop("OPENAI_API_KEY is not set. Add it to your environment before running.",
       call. = FALSE)
}

# ---- Load and summarize the evidence ----------------------------------------

data <- read_csv("marketing_sample_data.csv", show_col_types = FALSE)

summary_tbl <- data %>%
  group_by(Region, Channel) %>%
  summarise(
    Total_Spend = sum(Spend, na.rm = TRUE),
    Total_Clicks = sum(Clicks, na.rm = TRUE),
    Total_Conversions = sum(Conversions, na.rm = TRUE),
    Avg_Conversion_Rate = if_else(
      Total_Clicks > 0,
      round(100 * Total_Conversions / Total_Clicks, 2),
      NA_real_
    ),
    .groups = "drop"
  ) %>%
  arrange(desc(Avg_Conversion_Rate))

analysis_context <- paste(capture.output(print(summary_tbl, n = Inf)), collapse = "\n")

# ---- API helper --------------------------------------------------------------

call_gpt <- function(prompt_text, api_key, model_name) {
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    encode = "json",
    body = list(
      model = model_name,
      messages = list(
        list(
          role = "system",
          content = paste(
            "You are a careful marketing analyst.",
            "Use only the supplied evidence table.",
            "Separate observed facts from interpretation and do not invent causes."
          )
        ),
        list(role = "user", content = prompt_text)
      )
    )
  )

  stop_for_status(response)
  parsed <- content(response, as = "parsed", type = "application/json")

  if (is.null(parsed$choices[[1]]$message$content)) {
    stop("The API response did not contain message content.", call. = FALSE)
  }

  parsed$choices[[1]]$message$content
}

# ---- Grounded prompts --------------------------------------------------------

prompt_summary <- glue(
  "Write a concise three-paragraph executive summary of the evidence below.\n",
  "Identify the strongest and weakest region-channel combinations using the ",
  "reported spend, clicks, conversions, and conversion rates. Do not claim why ",
  "a result occurred unless the table itself establishes the reason.\n\n",
  "EVIDENCE TABLE\n{analysis_context}"
)

prompt_patterns <- glue(
  "Analyze cross-sectional performance patterns in the evidence below. Compare ",
  "regions and channels, flag material differences, and identify questions that ",
  "would require time-series or causal evidence. Do not describe improvement or ",
  "decline because the table contains no time dimension.\n\n",
  "EVIDENCE TABLE\n{analysis_context}"
)

prompt_recommendations <- glue(
  "Propose three proportionate marketing actions based only on the evidence ",
  "below. For each action, name the supporting metric, state the uncertainty, ",
  "and recommend a check or experiment before a large budget change.\n\n",
  "EVIDENCE TABLE\n{analysis_context}"
)

gpt_summary <- call_gpt(prompt_summary, api_key, model_name)
gpt_patterns <- call_gpt(prompt_patterns, api_key, model_name)
gpt_recommendations <- call_gpt(prompt_recommendations, api_key, model_name)

# ---- Publish -----------------------------------------------------------------

wb <- createWorkbook()
addWorksheet(wb, "Raw Data")
addWorksheet(wb, "Summary Table")
addWorksheet(wb, "Executive Summary")
addWorksheet(wb, "Performance Patterns")
addWorksheet(wb, "Recommendations")

writeData(wb, "Raw Data", data, withFilter = TRUE)
writeData(wb, "Summary Table", summary_tbl, withFilter = TRUE)
writeData(wb, "Executive Summary", gpt_summary)
writeData(wb, "Performance Patterns", gpt_patterns)
writeData(wb, "Recommendations", gpt_recommendations)

for (sheet in names(wb)) {
  freezePane(wb, sheet, firstRow = TRUE)
  setColWidths(wb, sheet, cols = 1:20, widths = "auto")
}

saveWorkbook(wb, "gpt_marketing_report.xlsx", overwrite = TRUE)
message("Report generated: gpt_marketing_report.xlsx")

