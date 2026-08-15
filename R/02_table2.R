#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop("Run with Rscript R/02_table2.R from any directory.")
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
  "table5a_v4.csv"
)
selection_file <- file.path(
  project_root,
  "data",
  "aggregate",
  "table2_editorial_selection.csv"
)
output_dir <- file.path(project_root, "outputs", "tables")

if (!file.exists(input_file)) {
  stop("Missing public aggregate input: data/aggregate/table5a_v4.csv")
}
if (!file.exists(selection_file)) {
  stop(
    "Missing approved public editorial-selection manifest: ",
    "data/aggregate/table2_editorial_selection.csv"
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

table2_source <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)
editorial_selection <- read.csv(
  selection_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

if (
  !identical(names(editorial_selection), "Characteristic") ||
    anyDuplicated(editorial_selection$Characteristic)
) {
  stop("Unexpected Table 2 editorial-selection schema.")
}

# Keep the publication order defined in the editorial selection file.
table2_data <- table2_source[
  match(editorial_selection$Characteristic, table2_source$Characteristic),
  ,
  drop = FALSE
]

if (anyNA(table2_data$Characteristic) || nrow(table2_data) != 41L) {
  stop("Unexpected Table 2 selection; expected 41 documented rows.")
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(
  table2_data,
  file.path(output_dir, "table2.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8",
  na = ""
)

table2_document <- officer::read_docx()
table2_document <- officer::body_add_par(
  table2_document,
  "Table 2",
  style = "heading 1"
)
table2_document <- flextable::body_add_flextable(
  table2_document,
  flextable::flextable(table2_data)
)
print(
  table2_document,
  target = file.path(output_dir, "table2.docx")
)

cat("Table 2 generated.\n")
