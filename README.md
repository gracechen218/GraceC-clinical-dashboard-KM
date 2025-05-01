# Clinical Trial Dashboard (Shiny App)

This R Shiny app is a simple interactive dashboard built to demonstrate clinical programming concepts such as survival analysis, adverse event summaries, and subgroup exploration.

## Features

- Kaplan-Meier survival curves using `survival` and `survminer`
- Treatment group filtering
- Adverse event (AE) bar chart by occurrence
- Summary statistics for selected subgroup
- Reactive UI with tabbed navigation

## Mock Data

The app uses simulated clinical trial data, mimicking an ADTTE-like dataset:
- `AVAL`: Time-to-event
- `CNSR`: Censoring flag
- `TRT01P`: Treatment group
- `AEFLAG`: AE presence indicator


