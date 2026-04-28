
library(tidyverse)
library(readxl)
library(finalfit)

# ── 1. Import data ────────────────────────────────────────────────────────────
OV_predictors_Data <- read_excel(path = "data for project 7.xlsx")

# ── 2. Factor encoding ────────────────────────────────────────────────────────
# Convert categorical variables to labeled factors for correct
# statistical handling and readable output in tables
OV_predictors_Data <- OV_predictors_Data %>% mutate(
  Ascitis = factor(Ascitis, levels = c("0", "1"), labels = c("No", "Yes")),
  `Portal Hypertension Gastropathy` = factor(`Portal Hypertension Gastropathy`,
                                             levels = c("0", "1"), labels = c("No", "Yes")),
  `Child-Pough Score` = factor(`Child-Pough Score`),
  Sex = factor(Sex, levels = c("1", "2"), labels = c("Male", "Female")),
  `Varices Size` = factor(`Varices Size`, levels = c("0", "1"),
                          labels = c("No Varices", "With Varices"))
)

