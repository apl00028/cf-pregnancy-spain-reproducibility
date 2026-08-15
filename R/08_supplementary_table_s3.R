#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop(
    "Run with Rscript R/08_supplementary_table_s3.R ",
    "from any directory."
  )
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
  "supplementary_table_s3.csv"
)
output_dir <- file.path(project_root, "outputs", "supplementary")

if (!file.exists(input_file)) {
  stop(
    "Missing public aggregate input: ",
    "data/aggregate/supplementary_table_s3.csv"
  )
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

table_s3_data <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  table_s3_data,
  file.path(output_dir, "supplementary_table_s3.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

table_s3_document <- officer::read_docx()
table_s3_document <- officer::body_add_par(
  table_s3_document,
  "Supplementary Table S3",
  style = "heading 1"
)
table_s3_document <- flextable::body_add_flextable(
  table_s3_document,
  flextable::flextable(table_s3_data)
)
print(
  table_s3_document,
  target = file.path(output_dir, "supplementary_table_s3.docx")
)

cat("Supplementary Table S3 generated.\n")
