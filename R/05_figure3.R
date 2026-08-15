#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop("Run with Rscript R/05_figure3.R from any directory.")
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
  "figure3_marginal_means.csv"
)
output_dir <- file.path(project_root, "outputs", "figures")

if (!file.exists(input_file)) {
  stop(
    "Missing public aggregate input: ",
    "data/aggregate/figure3_marginal_means.csv"
  )
}

figure3_data <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

expected_columns <- c(
  "panel",
  "outcome",
  "timepoint",
  "x_label",
  "timepoint_order",
  "estimate",
  "lower_95_CI",
  "upper_95_CI",
  "source"
)
if (!identical(names(figure3_data), expected_columns)) {
  stop("Unexpected Figure 3 aggregate schema.")
}

draw_panel <- function(panel_data) {
  panel_data <- panel_data[
    order(panel_data$timepoint_order),
    ,
    drop = FALSE
  ]
  y_range <- range(panel_data$lower_95_CI, panel_data$upper_95_CI)
  y_padding <- diff(y_range) * 0.12

  if (y_padding == 0) {
    y_padding <- 1
  }

  plot(
    panel_data$timepoint_order,
    panel_data$estimate,
    type = "n",
    xaxt = "n",
    xlim = c(0.7, max(panel_data$timepoint_order) + 0.3),
    ylim = y_range + c(-y_padding, y_padding),
    xlab = "",
    ylab = panel_data$outcome[1],
    bty = "l"
  )
  abline(v = 4.5, lty = 2, col = "#777777")
  arrows(
    panel_data$timepoint_order,
    panel_data$lower_95_CI,
    panel_data$timepoint_order,
    panel_data$upper_95_CI,
    angle = 90,
    code = 3,
    length = 0.035,
    lwd = 0.9,
    col = "#0072B2"
  )
  lines(
    panel_data$timepoint_order,
    panel_data$estimate,
    col = "#0072B2",
    lwd = 1.4
  )
  points(
    panel_data$timepoint_order,
    panel_data$estimate,
    pch = 16,
    col = "#0072B2"
  )
  axis(
    1,
    at = panel_data$timepoint_order,
    labels = panel_data$x_label,
    cex.axis = 0.8
  )
  mtext("Pregnancy", side = 1, line = 2.2, at = 2.5, cex = 0.75)
  mtext("Postpartum", side = 1, line = 2.2, at = 5.5, cex = 0.75)
}

draw_figure3 <- function() {
  par(
    mfrow = c(1, 3),
    mar = c(4.6, 4.2, 2.4, 1),
    oma = c(0, 0, 1.3, 0)
  )

  for (panel in c("A", "B", "C")) {
    panel_data <- figure3_data[
      figure3_data$panel == panel,
      ,
      drop = FALSE
    ]
    draw_panel(panel_data)
    title(
      paste0(panel, ". ", panel_data$outcome[1]),
      adj = 0,
      cex.main = 0.95
    )
  }

  mtext(
    "Model-based marginal mean (95% CI)",
    side = 3,
    outer = TRUE,
    line = 0.2,
    cex = 0.95
  )
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  figure3_data,
  file.path(output_dir, "figure3_model_based_trajectories.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

pdf(
  file.path(output_dir, "figure3_model_based_trajectories.pdf"),
  width = 11,
  height = 4.4
)
draw_figure3()
dev.off()

png(
  file.path(output_dir, "figure3_model_based_trajectories.png"),
  width = 2200,
  height = 880,
  res = 200
)
draw_figure3()
dev.off()

tiff(
  file.path(output_dir, "figure3_model_based_trajectories.tiff"),
  width = 2200,
  height = 880,
  res = 200,
  compression = "lzw"
)
draw_figure3()
dev.off()

cat("Figure 3 generated.\n")
