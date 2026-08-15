#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop("Run with Rscript R/03_figure1.R from any directory.")
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
  "figure1_counts.csv"
)
output_dir <- file.path(project_root, "outputs", "figures")

if (!file.exists(input_file)) {
  stop("Missing public aggregate input: data/aggregate/figure1_counts.csv")
}

figure1_counts <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

expected_columns <- c(
  "count",
  "observed",
  "expected",
  "status",
  "canonical_source"
)
if (!identical(names(figure1_counts), expected_columns)) {
  stop("Unexpected Figure 1 aggregate schema.")
}

count_value <- function(key) {
  count <- figure1_counts$observed[match(key, figure1_counts$count)]

  if (length(count) != 1L || is.na(count)) {
    stop("Missing required Figure 1 aggregate count: ", key)
  }

  count
}

draw_node <- function(center_x, center_y, width, height, label, fill = "#EAF2F8") {
  rect(
    center_x - width / 2,
    center_y - height / 2,
    center_x + width / 2,
    center_y + height / 2,
    col = fill,
    border = "#2C3E50",
    lwd = 1.1
  )
  text(center_x, center_y, label, cex = 0.76)
}

draw_arrow <- function(x1, y1, x2, y2) {
  arrows(x1, y1, x2, y2, length = 0.07, lwd = 1)
}

draw_figure1 <- function() {
  par(mar = c(1.5, 1.5, 2, 1.5), family = "sans")
  plot.new()
  plot.window(xlim = c(0, 1), ylim = c(0, 1))
  title(
    "Figure 1. Cohort flow and analytic subsets",
    line = 0.3,
    cex.main = 1.05
  )

  draw_node(
    0.50,
    0.90,
    0.34,
    0.09,
    sprintf(
      "Pregnancy episodes\nN = %d; centres = %d",
      count_value("overall_episodes"),
      count_value("overall_centres")
    )
  )

  draw_arrow(0.50, 0.855, 0.50, 0.80)
  draw_node(
    0.50,
    0.75,
    0.38,
    0.09,
    sprintf(
      "Calendar-era assignment\nAssignable: %d; missing: %d",
      count_value("era_assignable"),
      count_value("era_missing")
    )
  )

  draw_arrow(0.41, 0.705, 0.25, 0.64)
  draw_arrow(0.59, 0.705, 0.75, 0.64)
  draw_node(
    0.25,
    0.59,
    0.30,
    0.09,
    sprintf("Pre-ETI-access era\nn = %d", count_value("era_pre")),
    "#F2F2F2"
  )
  draw_node(
    0.75,
    0.59,
    0.30,
    0.09,
    sprintf("ETI-access era\nn = %d", count_value("era_eti")),
    "#D9EAD3"
  )

  draw_arrow(0.50, 0.705, 0.50, 0.49)
  draw_node(
    0.50,
    0.44,
    0.42,
    0.10,
    sprintf(
      "Pulmonary function available\nppFEV1: %d episodes; %d measurements",
      count_value("ppfev1_descriptive_episodes"),
      count_value("ppfev1_descriptive_measurements")
    ),
    "#EAF2F8"
  )

  draw_arrow(0.50, 0.39, 0.50, 0.30)
  draw_node(
    0.50,
    0.25,
    0.42,
    0.10,
    sprintf(
      "Primary ppFEV1 analysis\n%d episodes; %d mothers; %d measurements",
      count_value("ppfev1_primary_episodes"),
      count_value("ppfev1_primary_mothers"),
      count_value("ppfev1_primary_measurements")
    ),
    "#D9EAD3"
  )
  draw_node(
    0.17,
    0.25,
    0.25,
    0.10,
    sprintf(
      "Preterm primary\n%d episodes; %d mothers",
      count_value("preterm_primary_episodes"),
      count_value("preterm_primary_mothers")
    ),
    "#FCF3CF"
  )
  draw_node(
    0.83,
    0.25,
    0.25,
    0.10,
    sprintf(
      "Exacerbation primary\n%d episodes; %d mothers",
      count_value("exacerbation_primary_episodes"),
      count_value("exacerbation_primary_mothers")
    ),
    "#FDEDEC"
  )

  draw_arrow(0.33, 0.44, 0.22, 0.30)
  draw_arrow(0.67, 0.44, 0.78, 0.30)
  text(
    0.50,
    0.07,
    "Counts are validated public aggregates; no individual-level records are used.",
    cex = 0.65
  )
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  figure1_counts,
  file.path(output_dir, "figure1_counts.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

pdf(file.path(output_dir, "figure1.pdf"), width = 8, height = 6)
draw_figure1()
dev.off()

png(
  file.path(output_dir, "figure1.png"),
  width = 1600,
  height = 1200,
  res = 200
)
draw_figure1()
dev.off()

cat("Figure 1 generated.\n")
