#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop("Run with Rscript R/04_figure2.R from any directory.")
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
  "figure2_by_year.csv"
)
output_dir <- file.path(project_root, "outputs", "figures")

if (!file.exists(input_file)) {
  stop("Missing public aggregate input: data/aggregate/figure2_by_year.csv")
}

figure2_data <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

expected_columns <- c(
  "year",
  "n_pregnancy_episodes",
  "calendar_era"
)
if (!identical(names(figure2_data), expected_columns)) {
  stop("Unexpected Figure 2 aggregate schema.")
}

draw_figure2 <- function() {
  pre_eti <- figure2_data$calendar_era == "Pre-ETI-access era"
  bar_colours <- ifelse(pre_eti, "#BDBDBD", "#0072B2")
  bar_midpoints <- barplot(
    figure2_data$n_pregnancy_episodes,
    col = bar_colours,
    border = NA,
    space = 0.15,
    axes = FALSE,
    ylim = c(0, max(figure2_data$n_pregnancy_episodes) + 5),
    xlab = "Calendar year of estimated gestational start",
    ylab = "Number of pregnancy episodes"
  )

  axis(2, las = 1)
  year_ticks <- seq(1, nrow(figure2_data), by = 2)
  axis(
    1,
    at = bar_midpoints[year_ticks],
    labels = figure2_data$year[year_ticks],
    las = 2,
    cex.axis = 0.7
  )

  first_eti_bar <- which(!pre_eti)[1L]
  last_pre_eti_bar <- which(pre_eti)[length(which(pre_eti))]
  abline(
    v = (bar_midpoints[first_eti_bar] + bar_midpoints[last_pre_eti_bar]) / 2,
    lty = 2,
    col = "#4D4D4D"
  )

  text(
    mean(bar_midpoints[pre_eti]),
    max(figure2_data$n_pregnancy_episodes) + 3.4,
    sprintf(
      "Pre-ETI-access era\nn=%d",
      sum(figure2_data$n_pregnancy_episodes[pre_eti])
    ),
    cex = 0.82
  )
  text(
    mean(bar_midpoints[!pre_eti]),
    max(figure2_data$n_pregnancy_episodes) + 3.4,
    sprintf(
      "ETI-access era\nn=%d",
      sum(figure2_data$n_pregnancy_episodes[!pre_eti])
    ),
    cex = 0.82
  )
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  figure2_data,
  file.path(output_dir, "figure2_data.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

pdf(file.path(output_dir, "figure2.pdf"), width = 8, height = 5)
draw_figure2()
dev.off()

png(
  file.path(output_dir, "figure2.png"),
  width = 1600,
  height = 1000,
  res = 200
)
draw_figure2()
dev.off()

svg(file.path(output_dir, "figure2.svg"), width = 8, height = 5)
draw_figure2()
dev.off()

cat("Figure 2 generated.\n")
