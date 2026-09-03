
# generate_gpt_report.R

library(tidyverse)
library(openxlsx)
library(httr)
library(jsonlite)
library(glue)

# === Load Marketing Data ===
data <- read_csv("marketing_sample_data.csv")

# === Summarize Key Metrics ===
summary_tbl <- data %>%
  group_by(Region, Channel) %>%
  summarise(
    Total_Spend = sum(Spend),
    Total_Clicks = sum(Clicks),
    Total_Conversions = sum(Conversions),
    Avg_Conversion_Rate = round(100 * sum(Conversions) / sum(Clicks), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(Avg_Conversion_Rate))

# === GPT API Function ===
call_gpt <- function(prompt_text, api_key = Sys.getenv("OPENAI_API_KEY")) {
  res <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      messages = list(
        list(role = "system", content = "You are a marketing analytics expert."),
        list(role = "user", content = prompt_text)
      )
    )
  )
  content(res)$choices[[1]]$message$content
}

# === Step 1: Executive Summary Prompt ===
prompt1 <- glue("
Using the following marketing data summary, generate a 3-paragraph executive summary. 
Explain which regions or channels performed best and why.

{paste(capture.output(print(summary_tbl)), collapse='\n')}
")

# === Step 2: Trend Analysis Prompt ===
prompt2 <- glue("
Based on the above data, analyze trends across regions and channels.
Are there any clear improvements or declines that should be noted?
")

# === Step 3: Recommendations Prompt ===
prompt3 <- glue("
Give three specific strategic recommendations for the marketing team.
Base these on performance metrics (e.g., conversion rate, cost efficiency).
")

# === Run GPT Prompts ===
# Comment these out and replace with fake output if you don't have API access
gpt_summary <- call_gpt(prompt1)
gpt_trends <- call_gpt(prompt2)
gpt_recommendations <- call_gpt(prompt3)

# === Save to Excel Report ===
wb <- createWorkbook()
addWorksheet(wb, "Raw Data")
addWorksheet(wb, "Summary Table")
addWorksheet(wb, "GPT Executive Summary")
addWorksheet(wb, "GPT Trend Analysis")
addWorksheet(wb, "GPT Recommendations")

writeData(wb, "Raw Data", data)
writeData(wb, "Summary Table", summary_tbl)
writeData(wb, "GPT Executive Summary", gpt_summary)
writeData(wb, "GPT Trend Analysis", gpt_trends)
writeData(wb, "GPT Recommendations", gpt_recommendations)

saveWorkbook(wb, "gpt_marketing_report.xlsx", overwrite = TRUE)
cat("✅ Report generated: gpt_marketing_report.xlsx\n")
