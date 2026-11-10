# Build tidy long-format data for the Atmospheric Concentrations of Greenhouse Gases indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Source cells are blank wherever a series has no measurement for that row, so a
# populated cell becomes one output row and a blank cell becomes none.
# `label_rows_ok` names the section-divider rows ("Ice core measurements") that
# sit in the Year column with every series blank; they carry no data and are
# dropped, and anything else non-numeric in the Year column stops the build.
reshape_long <- function(raw, id_src, id_out, series_cols, label_rows_ok = character(), what) {
  # A row with nothing in it at all (one sits mid-file in Figure 1) carries no data.
  empty <- Reduce(`&`, lapply(raw, function(x) trimws(x) == ""))
  raw <- raw[!empty, , drop = FALSE]

  is_label <- raw[[id_src]] %in% label_rows_ok
  if (any(is_label)) {
    stopifnot(all(vapply(raw[is_label, series_cols], function(x) all(trimws(x) == ""), logical(1))))
  }
  d <- raw[!is_label, , drop = FALSE]

  # Figure 5 spells "no measurement" as the word null for the troposphere and
  # stratosphere in 1994 to 1996, when only the total column is available.
  d[series_cols] <- lapply(d[series_cols], function(x) ifelse(x == "null", "", x))

  bad <- d[[id_src]][is.na(suppressWarnings(as.numeric(d[[id_src]])))]
  if (length(bad)) {
    stop("Non-numeric value(s) in the Year column of ", what, ": ",
         paste(sQuote(unique(bad)), collapse = ", "), call. = FALSE)
  }

  # EPA prints values of 1,000 or more with a thousands separator ("1,872.04").
  # Only the separator is removed; every digit is kept as published.
  d[series_cols] <- lapply(d[series_cols], function(x) gsub(",", "", x, fixed = TRUE))
  present <- unlist(d[series_cols])
  present <- present[trimws(present) != ""]
  stopifnot(!anyNA(suppressWarnings(as.numeric(present))))

  out <- tidyr::pivot_longer(
    d, cols = dplyr::all_of(series_cols), names_to = "series", values_to = "value",
    values_drop_na = FALSE
  )
  out <- out[trimws(out$value) != "", , drop = FALSE]
  out[[id_out]] <- out[[id_src]]
  out <- out[c(id_out, "series", "value")]
  assert_conservation(d, series_cols, nrow(out), what)
  out
}

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Atmospheric Concentrations of Greenhouse Gases",
  slug                    = "atmospheric-concentrations",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-atmospheric-concentrations-greenhouse-gases/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-06/ghg-concentrations_documentation.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Global Atmospheric Concentrations of Carbon Dioxide Over Time ----

f1_path <- file.path(raw_dir, "ghg-concentrations_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f1_raw,
  id_cols          = character(),
  expected_headers = c("Year", "Antarctic Ice Cores", "Mauna Loa", "Barrow", "Cape Matatula", "South Pole", "Cape Grim", "Lampedusa", "Shetland"),
  what             = "ghg-concentrations_fig-1.csv"
)

# Long format: one row per populated cell. year_ce is a decimal calendar year; negative values are BC.
f1 <- reshape_long(
  f1_raw, id_src = "Year", id_out = "year_ce",
  series_cols = setdiff(names(f1_raw), "Year"),
  label_rows_ok = c("Ice core measurements"),
  what = "ghg-concentrations_fig-1.csv"
)

write_csv_stable(f1, file.path(out_dir, "co2_concentrations.csv"))

# ---- Figure 2: Global Atmospheric Concentrations of Methane Over Time ----

f2_path <- file.path(raw_dir, "ghg-concentrations_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = character(),
  expected_headers = c("Year (negative values = BC)", "EPICA Dome C, Antarctica", "Law Dome", "Cape Grim, Australia", "Mauna Loa, Hawaii", "Shetland Islands, Scotland"),
  what             = "ghg-concentrations_fig-2.csv"
)

# Long format: one row per populated cell. year_ce is a decimal calendar year; negative values are BC.
f2 <- reshape_long(
  f2_raw, id_src = "Year (negative values = BC)", id_out = "year_ce",
  series_cols = setdiff(names(f2_raw), "Year (negative values = BC)"),
  label_rows_ok = c("Ice core measurements"),
  what = "ghg-concentrations_fig-2.csv"
)

write_csv_stable(f2, file.path(out_dir, "methane_concentrations.csv"))

# ---- Figure 3: Global Atmospheric Concentrations of Nitrous Oxide Over Time ----

f3_path <- file.path(raw_dir, "ghg-concentrations_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f3_raw,
  id_cols          = character(),
  expected_headers = c("Year (negative values = BC)", "EPICA Dome C, Antarctica", "Antarctica (Battle et al.)", "Cape Grim, Australia", "Mauna Loa, Hawaii", "South Pole, Antarctica", "Barrow, Alaska"),
  what             = "ghg-concentrations_fig-3.csv"
)

# Long format: one row per populated cell. year_ce is a decimal calendar year; negative values are BC.
f3 <- reshape_long(
  f3_raw, id_src = "Year (negative values = BC)", id_out = "year_ce",
  series_cols = setdiff(names(f3_raw), "Year (negative values = BC)"),
  what = "ghg-concentrations_fig-3.csv"
)

write_csv_stable(f3, file.path(out_dir, "nitrous_oxide_concentrations.csv"))

# ---- Figure 4: Global Atmospheric Concentrations of Selected Halogenated Gases, 1978-2022 ----

f4_path <- file.path(raw_dir, "ghg-concentrations_fig-4.csv")
f4_meta <- read_epa_preamble(f4_path)
f4_raw  <- read_epa_csv(f4_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f4_raw,
  id_cols          = character(),
  expected_headers = c("Year", "HCFC-22", "HCFC-141b", "HFC-23", "HFC-125", "HFC-134a", "HFC-152a", "CFC-12", "Methyl chloroform", "Sulfur hexafluoride", "PFC-116", "Halon-1211", "Nitrogen trifluoride", "PFC-14"),
  what             = "ghg-concentrations_fig-4.csv"
)

# Long format: one row per populated cell. year_decimal is the monthly time step as a decimal year.
f4 <- reshape_long(
  f4_raw, id_src = "Year", id_out = "year_decimal",
  series_cols = setdiff(names(f4_raw), "Year"),
  what = "ghg-concentrations_fig-4.csv"
)

write_csv_stable(f4, file.path(out_dir, "halogenated_gases_concentrations.csv"))

# ---- Figure 5: Global Atmospheric Concentrations of Ozone, 1979-2020 ----

f5_path <- file.path(raw_dir, "ghg-concentrations_fig-5.csv")
f5_meta <- read_epa_preamble(f5_path)
f5_raw  <- read_epa_csv(f5_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f5_raw,
  id_cols          = character(),
  expected_headers = c("Year", "Total column: SBUV", "Troposphere", "Stratosphere"),
  what             = "ghg-concentrations_fig-5.csv"
)

# Long format: one row per populated cell. 1994 to 1996 carry only the total column.
f5 <- reshape_long(
  f5_raw, id_src = "Year", id_out = "year",
  series_cols = setdiff(names(f5_raw), "Year"),
  what = "ghg-concentrations_fig-5.csv"
)

write_csv_stable(f5, file.path(out_dir, "ozone_concentrations.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# Documents every output column, in order. `describe()` fails if the names it is
# given are not exactly the data frame's columns, so the dictionary cannot drift.
describe <- function(df, ...) {
  cols <- list(...)
  stopifnot(identical(vapply(cols, function(x) x$name, character(1)), names(df)))
  cols
}

id_year_ce <- col("year_ce", "number",
  "Calendar year as a decimal, from ice core ages and monitoring-site sample dates. Negative values are years BC.")
c_series <- function(what) col("series", "string", what)
c_value  <- function(unit) col("value", "number", paste("Measured atmospheric concentration,", unit))

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "co2_concentrations.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "ghg-concentrations_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1, id_year_ce, c_series("Ice core study or monitoring site that supplied the measurement."), c_value("in parts per million (ppm) of CO2."))
    ),
    list(
      file            = "methane_concentrations.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "ghg-concentrations_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(f2, id_year_ce, c_series("Ice core study or monitoring site that supplied the measurement."), c_value("in parts per billion (ppb) of methane."))
    ),
    list(
      file            = "nitrous_oxide_concentrations.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "ghg-concentrations_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = "UTF-8",
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = f3_meta$units,
      rows            = nrow(f3),
      columns         = describe(f3, id_year_ce, c_series("Ice core study or monitoring site that supplied the measurement."), c_value("in parts per billion (ppb) of nitrous oxide."))
    ),
    list(
      file            = "halogenated_gases_concentrations.csv",
      figure          = "Figure 4",
      figure_title    = f4_meta$title,
      source_file     = "ghg-concentrations_fig-4.csv",
      source_sha256   = file_sha256(f4_path),
      source_encoding = "UTF-8",
      data_source     = f4_meta$data_source,
      web_update      = f4_meta$web_update,
      unit            = f4_meta$units,
      rows            = nrow(f4),
      columns         = describe(f4, col("year_decimal", "number", "Decimal year of the measurement, for example 1978.04."), c_series("Halogenated gas, named as EPA labels it (for example HCFC-22)."), c_value("in parts per trillion (ppt)."))
    ),
    list(
      file            = "ozone_concentrations.csv",
      figure          = "Figure 5",
      figure_title    = f5_meta$title,
      source_file     = "ghg-concentrations_fig-5.csv",
      source_sha256   = file_sha256(f5_path),
      source_encoding = "UTF-8",
      data_source     = f5_meta$data_source,
      web_update      = f5_meta$web_update,
      unit            = f5_meta$units,
      rows            = nrow(f5),
      columns         = describe(f5, col("year", "integer", "Calendar year."), c_series("Layer of the atmosphere: total column, troposphere or stratosphere."), c_value("in Dobson units."))
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
