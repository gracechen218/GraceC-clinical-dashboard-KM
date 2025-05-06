# To make some sample ADTTE data


# Load packages -----------------------------------------------------------
library(tidyverse)
library(readr)
# install.packages("admiral.test"). #-- admiral has some sample row clinical data


# Make my sample TTE data -------------------------------------------------
adtte <- data.frame(
  USUBJID = paste0("SUBJ", 1:600),
  PARAMCD = sample(c("MAE", "Death","HFH"), 600, replace = TRUE),
  AVAL = sample(0:365, size = 600, replace = TRUE),
  CNSR = rbinom(600, 1, 0.3),
  TRT01P = sample(c("Device", "Placebo"), 600, replace = TRUE)
)

adtte2 <-
  adtte |> 
  mutate(event= case_when(
    CNSR == 1 ~  0 ,
    CNSR == 0 ~  1 ,
  ))


# Output to csv file ------------------------------------------------------
getwd()
write_csv(adtte2, "ADTTE.csv")



# Read in csv file --------------------------------------------------------

df <- read_csv("adtte.csv")
view(df)
