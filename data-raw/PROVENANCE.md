# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-atmospheric-concentrations-greenhouse-gases/index.html>  \
  sha256 `deef6a4d4ffaa2320374481bdc9f79a90f8e3c5abd24fe5d5c7fe6b2503c2d1a`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-06/ghg-concentrations_documentation.pdf>

## Figure data

- `ghg-concentrations_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/ghg-concentrations_fig-1.csv>  \
  sha256 `835ba64ddc78e881de55bcd550a4a8c5e29c9f1dcce9d0ec0e5f205a2e0c6843`  \
  encoding UTF-8, 1972 data rows, columns: `Year`, `Antarctic Ice Cores`, `Mauna Loa`, `Barrow`, `Cape Matatula`, `South Pole`, `Cape Grim`, `Lampedusa`, `Shetland`  \
  title: Figure 1. Global Atmospheric Concentrations of Carbon Dioxide Over Time  \
  data source: Compilation of 8 underlying datasets; web update: June 2024; units: parts per million (ppm) of CO2

- `ghg-concentrations_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/ghg-concentrations_fig-2.csv>  \
  sha256 `7fba7c2e481298187f5b8783958bd7270356065ae18b425b05cf43af11f13ee1`  \
  encoding UTF-8, 2218 data rows, columns: `Year (negative values = BC)`, `EPICA Dome C, Antarctica`, `Law Dome`, `Cape Grim, Australia`, `Mauna Loa, Hawaii`, `Shetland Islands, Scotland`  \
  title: Figure 2. Global Atmospheric Concentrations of Methane Over Time  \
  data source: Compilation of five underlying datasets; web update: June 2024; units: parts per billion (ppb) of methane

- `ghg-concentrations_fig-3.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/ghg-concentrations_fig-3.csv>  \
  sha256 `2454d9c6f016527f0971b6743301f12a8f2c85a5e054ac615af9ec70be1b21c4`  \
  encoding UTF-8, 958 data rows, columns: `Year (negative values = BC)`, `EPICA Dome C, Antarctica`, `Antarctica (Battle et al.)`, `Cape Grim, Australia`, `Mauna Loa, Hawaii`, `South Pole, Antarctica`, `Barrow, Alaska`  \
  title: Figure 3. Global Atmospheric Concentrations of Nitrous Oxide Over Time  \
  data source: Compilation of six underlying datasets; web update: June 2024; units: parts per billion (ppb) of nitrous oxide

- `ghg-concentrations_fig-4.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/ghg-concentrations_fig-4.csv>  \
  sha256 `06266f674ecf0ab2f8cf18d73929ffb9102d71a2caa38f82f8f50b83debc092a`  \
  encoding UTF-8, 906 data rows, columns: `Year`, `HCFC-22`, `HCFC-141b`, `HFC-23`, `HFC-125`, `HFC-134a`, `HFC-152a`, `CFC-12`, `Methyl chloroform`, `Sulfur hexafluoride`, `PFC-116`, `Halon-1211`, `Nitrogen trifluoride`, `PFC-14`  \
  title: Figure 4. Global Atmospheric Concentrations of Selected Halogenated Gases, 1978-2022  \
  data source: AGAGE, 2022; NOAA, 2023; Rigby, 2017.; web update: June 2024; units: parts per trillion (ppt)

- `ghg-concentrations_fig-5.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2022-07/ghg-concentrations_fig-5.csv>  \
  sha256 `28caa364275f3dfa55b4a8e40e058bdc800ffb96ed53f568a3e18daeff670a9f`  \
  encoding UTF-8, 42 data rows, columns: `Year`, `Total column: SBUV`, `Troposphere`, `Stratosphere`  \
  title: Figure 5. Global Atmospheric Concentrations of Ozone, 1979-2020  \
  data source: NASA, 2013, 2021, 2022; web update: July 2022; units: Dobson units
