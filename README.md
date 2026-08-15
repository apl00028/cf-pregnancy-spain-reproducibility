# Cystic fibrosis and pregnancy: tables and figures

This repository accompanies a clinical-epidemiological study of pregnancy episodes in people with cystic fibrosis. It contains the R code used to generate the study tables and figures.

The study datasets are not distributed because they contain sensitive clinical information. Generated tables and figures are also not included. Running the scripts therefore requires the corresponding study datasets in the paths referenced by the code.

## R scripts

The `R/` directory contains one script for each publication item:

- `01_table1.R` to `05_figure3.R`: main tables and figures.
- `06_supplementary_table_s1.R` to `09_supplementary_figure_s1.R`: supplementary tables and figure.
- `run_all.R`: runs the nine scripts in publication order.

Each script reads the required input from `data/aggregate/` and writes its result below `outputs/`. These directories are local and are not part of the public repository.

## Running with synthetic example data

The repository includes a generator for entirely artificial local inputs. These examples contain no study participant data, do not represent the study population, and are not intended to reproduce any published numerical result. They exist only to test that the public scripts execute.

From the repository root, generate the example inputs and run the analysis scripts with:

```sh
Rscript --vanilla R/00_generate_synthetic_data.R
Rscript R/run_all.R
```

The generator will not overwrite existing input files. Generated synthetic inputs under `data/` and generated outputs under `outputs/` remain local and gitignored.

## R environment

The package versions used by the project are recorded in `renv.lock`. From the repository root, restore them with:

```r
renv::restore()
```

When the study datasets are available in the expected locations, run all scripts from the repository root with:

```sh
Rscript R/run_all.R
```

Individual scripts can also be run in the same way, for example:

```sh
Rscript R/01_table1.R
```

Citation metadata are provided in `CITATION.cff`. The repository licence remains pending as described in `LICENSE_PENDING.md`.
