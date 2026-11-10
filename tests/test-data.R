# Regression checks on the generated data for the Atmospheric Concentrations of Greenhouse Gases indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 5 dataset(s)", length(meta$datasets) == 5L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pinned as strings so source precision is checked, not just magnitude. Each
# entry: row count, first and last row in source order, the smallest and largest
# value, and how many series carry data.
snap <- list(
  "co2_concentrations.csv" = list(
    rows = 2168L, first = c("-803718.8684", "Antarctic Ice Cores", "207.2854401"),
    last = c("2023", "Cape Grim", "416.378"), min = "173.7136201", max = "421.987", series = 8L),
  "methane_concentrations.csv" = list(
    rows = 2264L, first = c("-797446.1", "EPICA Dome C, Antarctica", "399.3"),
    last = c("2023", "Cape Grim, Australia", "1872.04"), min = "0", max = "1929.05", series = 5L),
  "nitrous_oxide_concentrations.csv" = list(
    rows = 1043L, first = c("-796475", "EPICA Dome C, Antarctica", "254"),
    last = c("2023", "Barrow, Alaska", "336.9958333"), min = "185.5", max = "336.9958333", series = 5L),
  "halogenated_gases_concentrations.csv" = list(
    rows = 4948L, first = c("1978.04", "CFC-12", "264.3"),
    last = c("2022.916667", "Halon-1211", "2.901962733"), min = "0.00475", max = "544.642", series = 13L),
  "ozone_concentrations.csv" = list(
    rows = 120L, first = c("1979", "Total column: SBUV", "288.5425341"),
    last = c("2020", "Stratosphere", "242.178"), min = "27.892", max = "288.5425341", series = 3L)
)

for (f in names(snap)) {
  df <- rd(f)
  v  <- as.numeric(df$value)
  s  <- snap[[f]]
  check(sprintf("%s: %d rows", f, s$rows), nrow(df) == s$rows)
  check(sprintf("%s: first row is %s", f, paste(s$first, collapse = " | ")),
        identical(unname(unlist(df[1L, ])), s$first))
  check(sprintf("%s: last row is %s", f, paste(s$last, collapse = " | ")),
        identical(unname(unlist(df[nrow(df), ])), s$last))
  check(sprintf("%s: minimum value is %s", f, s$min), identical(df$value[which.min(v)], s$min))
  check(sprintf("%s: maximum value is %s", f, s$max), identical(df$value[which.max(v)], s$max))
  check(sprintf("%s: %d series carry data", f, s$series), length(unique(df$series)) == s$series)
  check(sprintf("%s: every value parses as a number", f), !anyNA(v))
}

# EPA's Figure 3 file has a column for Battle et al. with no values in it, so it
# produces no rows; Figure 2 publishes two zero methane readings; and Figure 5
# has only the total column for 1994 to 1996.
check("nitrous oxide: the empty Battle et al. column produced no rows",
      !"Antarctica (Battle et al.)" %in% rd("nitrous_oxide_concentrations.csv")$series)
check("methane: EPA's two published zero readings are preserved as published",
      sum(rd("methane_concentrations.csv")$value == "0") == 2L)
oz <- rd("ozone_concentrations.csv")
check("ozone: 1994 to 1996 carry only the total column",
      identical(unique(oz$series[oz$year %in% c("1994", "1995", "1996")]), "Total column: SBUV"))

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
