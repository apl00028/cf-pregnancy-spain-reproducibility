#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop(
    "Run with Rscript R/06_supplementary_table_s1.R ",
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
  "supplementary_table_s1_counts.csv"
)
manifest_file <- file.path(
  project_root,
  "data",
  "aggregate",
  "s1_public_identifier_manifest.csv"
)
output_dir <- file.path(project_root, "outputs", "supplementary")

if (!file.exists(input_file)) {
  stop(
    "Missing approved public aggregate input: ",
    "data/aggregate/supplementary_table_s1_counts.csv"
  )
}
if (!file.exists(manifest_file)) {
  stop(
    "Missing fixed public identifier manifest: ",
    "data/aggregate/s1_public_identifier_manifest.csv"
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

table_s1_data <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)
table_s1_display <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8",
  colClasses = "character",
  na.strings = NULL
)
table_s1_display[is.na(table_s1_display)] <- ""

identifier_manifest <- read.csv(
  manifest_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

data_columns <- c(
  "public_identifier",
  "public_order",
  "episode_count",
  "percentage"
)
manifest_columns <- c(
  "public_identifier",
  "public_order",
  "display_label",
  "status",
  "notes"
)

if (
  !identical(names(table_s1_data), data_columns) ||
    !identical(names(table_s1_display), data_columns)
) {
  stop("Unexpected Supplementary Table S1 public aggregate schema.")
}
if (!identical(names(identifier_manifest), manifest_columns)) {
  stop("Unexpected Supplementary Table S1 identifier-manifest schema.")
}

required_identifiers <- sprintf("P%02d", 1:11)
valid_manifest <-
  nrow(identifier_manifest) == 11L &&
  !anyDuplicated(identifier_manifest$public_identifier) &&
  identical(
    identifier_manifest$public_identifier,
    required_identifiers
  ) &&
  identical(identifier_manifest$public_order, 1:11) &&
  all(
    identifier_manifest$display_label ==
      identifier_manifest$public_identifier
  ) &&
  all(identifier_manifest$status == "APPROVED_PUBLIC_IDENTIFIER")

if (!valid_manifest) {
  stop("Invalid fixed public identifier manifest.")
}

participant_rows <- table_s1_data[
  table_s1_data$public_identifier != "Overall",
  ,
  drop = FALSE
]
overall_row <- table_s1_data[
  table_s1_data$public_identifier == "Overall",
  ,
  drop = FALSE
]

valid_identifiers <-
  nrow(participant_rows) == 11L &&
  nrow(overall_row) == 1L &&
  !anyDuplicated(participant_rows$public_identifier) &&
  setequal(participant_rows$public_identifier, required_identifiers) &&
  !anyDuplicated(participant_rows$public_order) &&
  setequal(participant_rows$public_order, 1:11)

if (!valid_identifiers) {
  stop(
    "Invalid Supplementary Table S1 public aggregate identifiers or order."
  )
}

# Participant percentages are displayed after rounding and need not sum to 100.
valid_overall_row <-
  is.na(overall_row$public_order) &&
  overall_row$episode_count == sum(participant_rows$episode_count) &&
  is.finite(overall_row$percentage) &&
  all(is.finite(participant_rows$percentage)) &&
  all(participant_rows$percentage >= 0)

if (!valid_overall_row) {
  stop("Invalid Supplementary Table S1 Overall row.")
}

# Keep the approved neutral identifier order.
participant_rows <- participant_rows[
  match(
    identifier_manifest$public_identifier,
    participant_rows$public_identifier
  ),
  ,
  drop = FALSE
]
if (!identical(
  participant_rows$public_order,
  identifier_manifest$public_order
)) {
  stop("Public identifier order does not match the fixed manifest.")
}

display_participants <- table_s1_display[
  table_s1_display$public_identifier != "Overall",
  ,
  drop = FALSE
]
display_overall <- table_s1_display[
  table_s1_display$public_identifier == "Overall",
  ,
  drop = FALSE
]
display_participants <- display_participants[
  match(
    identifier_manifest$public_identifier,
    display_participants$public_identifier
  ),
  ,
  drop = FALSE
]
table_s1_output <- rbind(
  display_participants[
    order(as.integer(display_participants$public_order)),
    ,
    drop = FALSE
  ],
  display_overall
)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  table_s1_output,
  file.path(output_dir, "supplementary_table_s1.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8",
  na = ""
)

table_s1_document <- officer::read_docx()
table_s1_document <- officer::body_add_par(
  table_s1_document,
  "Supplementary Table S1",
  style = "heading 1"
)
table_s1_document <- flextable::body_add_flextable(
  table_s1_document,
  flextable::flextable(table_s1_output)
)
table_s1_document <- officer::body_add_par(
  table_s1_document,
  paste(
    "Participating institutions are represented by fixed neutral public",
    "identifiers (P01–P11). The correspondence with institutional names",
    "and internal codes is not included in the public repository."
  )
)
print(
  table_s1_document,
  target = file.path(output_dir, "supplementary_table_s1.docx")
)

cat("Supplementary Table S1 generated.\n")
