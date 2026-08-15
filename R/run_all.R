#!/usr/bin/env Rscript

# The study datasets are required but are not distributed with this repository.
args <- commandArgs(trailingOnly = FALSE)
script_path <- sub(
  "^--file=",
  "",
  args[grep("^--file=", args)]
)

if (length(script_path) != 1L) {
  stop("Run with Rscript R/run_all.R from any directory.")
}

project_root <- normalizePath(
  file.path(dirname(normalizePath(script_path)), ".."),
  winslash = "/",
  mustWork = TRUE
)

old_working_directory <- setwd(project_root)
on.exit(setwd(old_working_directory), add = TRUE)

# Use the project library when run with --vanilla.
renv_activation <- file.path(project_root, "renv", "activate.R")
if (file.exists(renv_activation)) {
  source(renv_activation, local = TRUE)
}

project_library <- .libPaths()[1L]
old_r_libs_user <- Sys.getenv("R_LIBS_USER", unset = "")
Sys.setenv(R_LIBS_USER = project_library)
on.exit(Sys.setenv(R_LIBS_USER = old_r_libs_user), add = TRUE)

rscript <- file.path(
  R.home("bin"),
  if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
)
if (!file.exists(rscript)) {
  stop("Rscript executable paired with this R session was not found.")
}

scripts <- c(
  "R/01_table1.R",
  "R/02_table2.R",
  "R/03_figure1.R",
  "R/04_figure2.R",
  "R/05_figure3.R",
  "R/06_supplementary_table_s1.R",
  "R/07_supplementary_table_s2.R",
  "R/08_supplementary_table_s3.R",
  "R/09_supplementary_figure_s1.R"
)

for (script in scripts) {
  cat("Running ", script, "\n", sep = "")
  exit_code <- system2(
    rscript,
    args = c("--vanilla", script)
  )

  if (exit_code != 0L) {
    stop("Script failed: ", script, call. = FALSE)
  }
}

cat("All table and figure scripts completed.\n")
