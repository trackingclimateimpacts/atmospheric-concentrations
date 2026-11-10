# Rights and attribution

## EPA content

The indicator text, figure captions, and underlying data reproduced in this
repository are works of the U.S. Environmental Protection Agency, prepared by
officers or employees of the U.S. Government as part of their official duties.
Under 17 U.S.C. 105 such works are not subject to copyright protection in the
United States.

Source: *Climate Change Indicators in the United States: Atmospheric Concentrations of Greenhouse Gases*,
U.S. EPA, as preserved in the January 19, 2025 snapshot of epa.gov.

<https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-atmospheric-concentrations-greenhouse-gases/index.html>

The underlying data are from Compilation of 8 underlying datasets. See the indicator's technical
documentation for details:

<https://19january2025snapshot.epa.gov/system/files/documents/2024-06/ghg-concentrations_documentation.pdf>

Files in `data-raw/` are reproduced unmodified from EPA's published per-figure
CSV downloads and are hashed in `data-raw/PROVENANCE.md`. Files in `data/` are
reformatted, not altered: values are preserved as source text byte for byte.
Every transformation is in `R/build_data.R` and is checked by
`tests/test-data.R`.

`narrative.qmd` is EPA's published wording, extracted from the indicator page
archived at `data-raw/source-page.html`.

## This rebuild

Code and the derived data schema are licensed CC-BY-SA.

This is an independent project. It is **not** affiliated with, endorsed by, or
approved by the U.S. Environmental Protection Agency or the agencies that
produced the underlying data.

The tidy files in `data/` reshape EPA's wide figure downloads into long format.
Blank cells, one fully blank row and the "Ice core measurements" divider row in
Figures 1 and 2 are dropped, the word `null` in Figure 5 is treated as a blank,
and the thousands separator in values such as `1,872.04` is removed. No digit of
any value is changed.
