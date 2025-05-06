# 📊 KM Survival Dashboard (R Shiny)

This is a web-based Shiny app for interactive Kaplan-Meier survival analysis.  
Users can upload their own clinical dataset and dynamically generate KM curves, filter by parameters, and view survival estimates at key time points (0, 30, and 180 days).

---

## 🚀 Features

- Upload clinical data in `.csv`, `.xlsx`, or `.sas7bdat` format
- Dynamically select:
  - Time-to-event variable
  - Censoring indicator
  - Grouping variable
  - `PARAMCD` filter (e.g., Death, MAE, HFH)
- Interactive Kaplan-Meier curve using `ggplot2` + `plotly`
- Summary survival probability table at 0, 30, and 180 days
- Works without `survminer` (uses tidyverse + broom workflow)

---

## 📂 File Structure
shiny-clinical-dashboard/
 ─ app.R # Main Shiny application file
 ─ README.md # You're reading it
 ─ ADTTE.csv # Sample ADTTE dataset for testing



