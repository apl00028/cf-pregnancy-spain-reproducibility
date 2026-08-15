#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop("Run with Rscript R/01_table1.R from any directory.")
}

project_root <- normalizePath(
  file.path(dirname(normalizePath(script_path)), ".."),
  winslash = "/",
  mustWork = TRUE
)

input_file <- file.path(
  project_root,
  "data",
  "aggregate",
  "table1.csv"
)
output_dir <- file.path(project_root, "outputs", "tables")

if (!file.exists(input_file)) {
  stop("Missing public aggregate input: data/aggregate/table1.csv")
}

if (
  !requireNamespace("officer", quietly = TRUE) ||
    !requireNamespace("flextable", quietly = TRUE)
) {
  stop(
    "Missing required packages: officer and flextable. ",
    "Packages are not installed automatically."
  )
}

table1_data <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)
table1_display <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8",
  colClasses = "character",
  na.strings = NULL
)
table1_display[is.na(table1_display)] <- ""

expected_columns <- c(
  "section",
  "variable",
  "row_type",
  "level",
  "available_n",
  "count",
  "percent",
  "display_value"
)

if (
  !identical(names(table1_data), expected_columns) ||
    !identical(names(table1_display), expected_columns)
) {
  stop("Unexpected Table 1 aggregate schema.")
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(
  table1_data,
  file.path(output_dir, "table1.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8",
  na = ""
)

table1_document <- officer::read_docx()
table1_document <- officer::body_add_par(
  table1_document,
  "Table 1",
  style = "heading 1"
)
table1_document <- flextable::body_add_flextable(
  table1_document,
  flextable::flextable(table1_display)
)
print(
  table1_document,
  target = file.path(output_dir, "table1.docx")
)

cat("Table 1 generated.\n")
