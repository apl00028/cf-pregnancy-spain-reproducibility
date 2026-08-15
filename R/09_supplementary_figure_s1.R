#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop(
    "Run with Rscript R/09_supplementary_figure_s1.R ",
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
  "supplementary_figure_s1_data.csv"
)
output_dir <- file.path(project_root, "outputs", "supplementary")

if (!file.exists(input_file)) {
  stop(
    "Missing public aggregate input: ",
    "data/aggregate/supplementary_figure_s1_data.csv"
  )
}

figure_s1_data <- read.csv(
  input_file,
  check.names = FALSE,
  stringsAsFactors = FALSE,
  fileEncoding = "UTF-8"
)

expected_columns <- c(
  "panel",
  "panel_population",
  "category",
  "count",
  "denominator",
  "percentage",
  "percentage_display",
  "display_label",
  "colour"
)
if (!identical(names(figure_s1_data), expected_columns)) {
  stop("Unexpected Supplementary Figure S1 aggregate schema.")
}

draw_donut <- function(panel_data, panel_letter) {
  panel_data <- panel_data[
    order(panel_data$category),
    ,
    drop = FALSE
  ]
  par(mar = c(1, 1, 3.4, 10), xpd = NA)

  pie(
    panel_data$count,
    labels = NA,
    col = panel_data$colour,
    border = "white",
    clockwise = TRUE,
    init.angle = 90
  )
  symbols(
    0,
    0,
    circles = 0.42,
    inches = FALSE,
    add = TRUE,
    bg = "white",
    fg = "white"
  )
  text(
    0,
    0,
    sprintf("N = %d", panel_data$denominator[1]),
    cex = 1.05
  )
  title(
    paste(
      c(
        paste0(panel_letter, "."),
        strwrap(panel_data$panel_population[1], width = 48)
      ),
      collapse = "\n"
    ),
    line = 0.3,
    cex.main = 0.88
  )
  legend(
    1.12,
    0.65,
    legend = panel_data$display_label,
    fill = panel_data$colour,
    bty = "n",
    cex = 0.63,
    xjust = 0,
    yjust = 1
  )
}

draw_figure_s1 <- function() {
  par(mfrow = c(2, 1))
  draw_donut(
    figure_s1_data[figure_s1_data$panel == "a", , drop = FALSE],
    "A"
  )
  draw_donut(
    figure_s1_data[figure_s1_data$panel == "b", , drop = FALSE],
    "B"
  )
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  figure_s1_data,
  file.path(output_dir, "supplementary_figure_s1_data.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

pdf(
  file.path(output_dir, "supplementary_figure_s1.pdf"),
  width = 11.5,
  height = 10
)
draw_figure_s1()
dev.off()

png(
  file.path(output_dir, "supplementary_figure_s1.png"),
  width = 2300,
  height = 2000,
  res = 200
)
draw_figure_s1()
dev.off()

cat("Supplementary Figure S1 generated.\n")
