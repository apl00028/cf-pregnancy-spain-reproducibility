#!/usr/bin/env Rscript

# Synthetic example inputs for testing the public analysis code.
#
# These data are entirely artificial. They do not represent study
# participants and are not intended to reproduce the published results.

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop(
    "Run with Rscript --vanilla R/00_generate_synthetic_data.R ",
    "from any directory."
  )
}

project_root <- normalizePath(
  file.path(dirname(normalizePath(script_path)), ".."),
  winslash = "/",
  mustWork = TRUE
)
aggregate_dir <- file.path(project_root, "data", "aggregate")

output_files <- c(
  "table1.csv",
  "table5a_v4.csv",
  "table2_editorial_selection.csv",
  "figure1_counts.csv",
  "figure2_by_year.csv",
  "figure3_marginal_means.csv",
  "supplementary_table_s1_counts.csv",
  "s1_public_identifier_manifest.csv",
  "supplementary_table_s2.csv",
  "supplementary_table_s3.csv",
  "supplementary_figure_s1_data.csv"
)

existing_files <- output_files[
  file.exists(file.path(aggregate_dir, output_files))
]
if (length(existing_files) > 0L) {
  stop(
    "Refusing to overwrite existing input file(s): ",
    paste(existing_files, collapse = ", "),
    ". Remove or relocate them before generating synthetic examples."
  )
}

dir.create(aggregate_dir, recursive = TRUE, showWarnings = FALSE)
set.seed(20260815)

write_synthetic_csv <- function(data, filename) {
  write.csv(
    data,
    file.path(aggregate_dir, filename),
    row.names = FALSE,
    fileEncoding = "UTF-8",
    na = ""
  )
}

table1_total <- sample(36:48, 1)
category_a_count <- sample(12:(table1_total - 12), 1)
category_b_count <- table1_total - category_a_count
complete_count <- sample(24:(table1_total - 2), 1)
missing_count <- table1_total - complete_count

table1_data <- data.frame(
  section = c(
    "Synthetic measurements",
    "Synthetic measurements",
    "Synthetic categories",
    "Synthetic categories",
    "Synthetic categories",
    "Synthetic completeness",
    "Synthetic completeness",
    "Synthetic completeness"
  ),
  variable = c(
    "Artificial score alpha",
    "Artificial score beta",
    "Artificial category gamma",
    "",
    "",
    "Artificial completeness flag",
    "",
    ""
  ),
  row_type = c(
    "continuous",
    "continuous",
    "categorical",
    "level",
    "level",
    "categorical",
    "level",
    "level"
  ),
  level = c(
    "",
    "",
    "",
    "Synthetic level A",
    "Synthetic level B",
    "",
    "Artificially complete",
    "Artificially missing"
  ),
  available_n = c(
    table1_total,
    table1_total - 3L,
    table1_total,
    NA_integer_,
    NA_integer_,
    table1_total,
    NA_integer_,
    NA_integer_
  ),
  count = c(
    NA_integer_,
    NA_integer_,
    NA_integer_,
    category_a_count,
    category_b_count,
    NA_integer_,
    complete_count,
    missing_count
  ),
  percent = c(
    NA_real_,
    NA_real_,
    NA_real_,
    round(100 * category_a_count / table1_total, 1),
    round(100 * category_b_count / table1_total, 1),
    NA_real_,
    round(100 * complete_count / table1_total, 1),
    round(100 * missing_count / table1_total, 1)
  ),
  display_value = c(
    sprintf("%.1f (synthetic SD %.1f)", runif(1, 40, 60), runif(1, 4, 9)),
    sprintf("%.1f [synthetic range %.1f-%.1f]", runif(1, 10, 20), 2.0, 28.0),
    "",
    sprintf(
      "%d (%.1f%%)",
      category_a_count,
      100 * category_a_count / table1_total
    ),
    sprintf(
      "%d (%.1f%%)",
      category_b_count,
      100 * category_b_count / table1_total
    ),
    "",
    sprintf(
      "%d (%.1f%%)",
      complete_count,
      100 * complete_count / table1_total
    ),
    sprintf(
      "%d (%.1f%%)",
      missing_count,
      100 * missing_count / table1_total
    )
  ),
  stringsAsFactors = FALSE
)
write_synthetic_csv(table1_data, "table1.csv")

characteristics <- sprintf("SYNTHETIC_CHARACTERISTIC_%02d", 1:41)
table2_source <- data.frame(
  Characteristic = characteristics,
  Group_A = sprintf("Artificial A-%02d", 1:41),
  Group_B = sprintf("Artificial B-%02d", 41:1),
  stringsAsFactors = FALSE
)
table2_source <- table2_source[sample(nrow(table2_source)), , drop = FALSE]
table2_selection <- data.frame(
  Characteristic = characteristics,
  stringsAsFactors = FALSE
)
write_synthetic_csv(table2_source, "table5a_v4.csv")
write_synthetic_csv(table2_selection, "table2_editorial_selection.csv")

synthetic_years <- 2091:2098
annual_counts <- sample(6:18, length(synthetic_years), replace = TRUE)
pre_eti_rows <- seq_len(4)
eti_rows <- 5:8
overall_episodes <- sum(annual_counts)
era_pre <- sum(annual_counts[pre_eti_rows])
era_eti <- sum(annual_counts[eti_rows])

descriptive_episodes <- as.integer(floor(overall_episodes * 0.78))
descriptive_measurements <- descriptive_episodes * 3L + 5L
primary_episodes <- descriptive_episodes - 7L
primary_mothers <- primary_episodes - 9L
primary_measurements <- primary_episodes * 3L
preterm_episodes <- as.integer(floor(overall_episodes * 0.32))
preterm_mothers <- max(1L, preterm_episodes - 4L)
exacerbation_episodes <- as.integer(floor(overall_episodes * 0.41))
exacerbation_mothers <- max(1L, exacerbation_episodes - 6L)

figure1_keys <- c(
  "overall_episodes",
  "overall_centres",
  "era_assignable",
  "era_missing",
  "era_pre",
  "era_eti",
  "ppfev1_descriptive_episodes",
  "ppfev1_descriptive_measurements",
  "ppfev1_primary_episodes",
  "ppfev1_primary_mothers",
  "ppfev1_primary_measurements",
  "preterm_primary_episodes",
  "preterm_primary_mothers",
  "exacerbation_primary_episodes",
  "exacerbation_primary_mothers"
)
figure1_values <- c(
  overall_episodes,
  sample(4:8, 1),
  overall_episodes,
  0L,
  era_pre,
  era_eti,
  descriptive_episodes,
  descriptive_measurements,
  primary_episodes,
  primary_mothers,
  primary_measurements,
  preterm_episodes,
  preterm_mothers,
  exacerbation_episodes,
  exacerbation_mothers
)
figure1_counts <- data.frame(
  count = figure1_keys,
  observed = as.integer(figure1_values),
  expected = as.integer(figure1_values),
  status = rep("SYNTHETIC", length(figure1_keys)),
  canonical_source = rep("synthetic_example", length(figure1_keys)),
  stringsAsFactors = FALSE
)
write_synthetic_csv(figure1_counts, "figure1_counts.csv")

figure2_data <- data.frame(
  year = synthetic_years,
  n_pregnancy_episodes = annual_counts,
  calendar_era = c(
    rep("Pre-ETI-access era", length(pre_eti_rows)),
    rep("ETI-access era", length(eti_rows))
  ),
  stringsAsFactors = FALSE
)
write_synthetic_csv(figure2_data, "figure2_by_year.csv")

make_trajectory <- function(panel, outcome, baseline) {
  timepoint_order <- 1:6
  estimate <- baseline + cumsum(runif(length(timepoint_order), -2.5, 2.5))
  interval_width <- runif(length(timepoint_order), 1.5, 4.5)

  data.frame(
    panel = panel,
    outcome = outcome,
    timepoint = sprintf("synthetic_timepoint_%d", timepoint_order),
    x_label = sprintf("Example %d", timepoint_order),
    timepoint_order = timepoint_order,
    estimate = round(estimate, 2),
    lower_95_CI = round(estimate - interval_width, 2),
    upper_95_CI = round(estimate + interval_width, 2),
    source = "synthetic_example",
    stringsAsFactors = FALSE
  )
}

figure3_data <- rbind(
  make_trajectory("A", "Synthetic outcome alpha", 25),
  make_trajectory("B", "Synthetic outcome beta", 75),
  make_trajectory("C", "Synthetic outcome gamma", 150)
)
write_synthetic_csv(figure3_data, "figure3_marginal_means.csv")

public_identifiers <- sprintf("P%02d", 1:11)
identifier_manifest <- data.frame(
  public_identifier = public_identifiers,
  public_order = 1:11,
  display_label = public_identifiers,
  status = "APPROVED_PUBLIC_IDENTIFIER",
  notes = "Synthetic execution example",
  stringsAsFactors = FALSE
)
write_synthetic_csv(identifier_manifest, "s1_public_identifier_manifest.csv")

institution_counts <- sample(3:14, length(public_identifiers), replace = TRUE)
institution_total <- sum(institution_counts)
institution_percentages <- round(
  100 * institution_counts / institution_total,
  1
)
table_s1_counts <- data.frame(
  public_identifier = c(public_identifiers, "Overall"),
  public_order = c(1:11, NA_integer_),
  episode_count = c(institution_counts, institution_total),
  percentage = c(institution_percentages, 100),
  stringsAsFactors = FALSE
)
write_synthetic_csv(
  table_s1_counts,
  "supplementary_table_s1_counts.csv"
)

# The public S2/S3 scripts do not encode a fixed input schema.
# These synthetic tables are therefore execution examples only and
# should not be interpreted as reconstructions of the publication data.
table_s2_data <- data.frame(
  Characteristic = sprintf("Synthetic S2 row %d", 1:4),
  Group_A = sprintf("Artificial A%d", 1:4),
  Group_B = sprintf("Artificial B%d", 1:4),
  stringsAsFactors = FALSE
)
table_s3_data <- data.frame(
  Characteristic = sprintf("Synthetic S3 row %d", 1:5),
  Group_A = sprintf("Example A%d", 1:5),
  Group_B = sprintf("Example B%d", 1:5),
  stringsAsFactors = FALSE
)
write_synthetic_csv(table_s2_data, "supplementary_table_s2.csv")
write_synthetic_csv(table_s3_data, "supplementary_table_s3.csv")

make_donut_panel <- function(panel, population, colours) {
  counts <- sample(5:20, length(colours), replace = TRUE)
  denominator <- sum(counts)
  percentages <- 100 * counts / denominator

  data.frame(
    panel = panel,
    panel_population = population,
    category = sprintf("synthetic_category_%d", seq_along(colours)),
    count = counts,
    denominator = denominator,
    percentage = round(percentages, 1),
    percentage_display = sprintf("%.1f%%", percentages),
    display_label = sprintf(
      "Artificial category %d: %.1f%%",
      seq_along(colours),
      percentages
    ),
    colour = colours,
    stringsAsFactors = FALSE
  )
}

figure_s1_data <- rbind(
  make_donut_panel(
    "a",
    "Entirely artificial example population A",
    c("#5B8FF9", "#61DDAA", "#F6BD16")
  ),
  make_donut_panel(
    "b",
    "Entirely artificial example population B",
    c("#7262FD", "#78D3F8", "#F6903D")
  )
)
write_synthetic_csv(
  figure_s1_data,
  "supplementary_figure_s1_data.csv"
)

cat(
  "Created 11 entirely artificial input files in data/aggregate/.\n",
  "These files are for execution testing only.\n",
  sep = ""
)
