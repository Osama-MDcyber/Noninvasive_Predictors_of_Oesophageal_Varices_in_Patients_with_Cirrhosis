

source(file = "Data Cleaning (OV Predictors).R")

library(gtsummary)
library(stringr)
library(flextable)
library(officer)
library(pROC)

# ── 3. Descriptive Table 1 ────────────────────────────────────────────────────
# Summarize baseline characteristics stratified by variceal status,
# with an overall column; exported as a flextable for Word compatibility
OV_predictors_Data %>% select(
  Age, Sex, `Child-Pough Score`, Ascitis, `Platelet Count`, INR,
  `Spleen Diameter`, `PV diameter(mm)`, `Gall Bladder Wall Thickness (mm)`,
  `Platelet count to spleen diameter ratio`, `Portal Hypertension Gastropathy`,
  Albumin, `Varices Size`
) %>% tbl_summary(by = `Varices Size`) %>% add_overall() %>%
  bold_labels() %>% as_flex_table()




# ── 4. ROC Curve Construction ─────────────────────────────────────────────────
# Build ROC objects for two candidate predictors of oesophageal varices:
#   - GBWT: Gall Bladder Wall Thickness (mm)
#   - Ratio: Platelet count to spleen diameter ratio
roc_gbwt  <- roc(OV_predictors_Data$`Varices Size`,
                 OV_predictors_Data$`Gall Bladder Wall Thickness (mm)`,
                 quiet = TRUE)
roc_ratio <- roc(OV_predictors_Data$`Varices Size`,
                 OV_predictors_Data$`Platelet count to spleen diameter ratio`,
                 quiet = TRUE)

# Print AUC estimates for each predictor
auc(roc_gbwt)
auc(roc_ratio)

# ── 5. Optimal Cutoffs (Youden Index) ────────────────────────────────────────
# Extract the best threshold for each predictor using the Youden index
# (maximises Sensitivity + Specificity - 1), with full operating characteristics
gbwt <- coords(roc_gbwt, x = "best",
               ret = c("threshold", "sensitivity", "specificity", "ppv", "npv"),
               best.method = "youden", transpose = F) %>% as.data.frame()
gbwt <- gbwt[1, ]   # Keep only the first optimal point if ties exist

ratio <- coords(roc_ratio, x = "best",
                ret = c("threshold", "sensitivity", "specificity", "ppv", "npv"),
                best.method = "youden", transpose = F) %>% as.data.frame()

# Standardize column names to title case; correct medical abbreviations
gbwt <- gbwt %>% rename_with(str_to_title) %>% rename("PPV" = Ppv, "NPV" = Npv)
ratio <- ratio %>% rename_with(str_to_title) %>% rename("PPV" = Ppv, "NPV" = Npv)

# ── 6. Performance Table ──────────────────────────────────────────────────────
# Combine both predictors into a single formatted table with AUC,
# optimal cutoff, and diagnostic accuracy metrics
predictor_label <- c("GBWT (mm)", "Platelet / spleen ratio")

bind_rows(gbwt, ratio) %>%
  remove_rownames() %>%
  mutate(
    Predictor = predictor_label,
    AUC = c(auc(roc_gbwt), auc(roc_ratio))
  ) %>%
  relocate(Predictor, .before = Threshold) %>%
  relocate(AUC, .after = Predictor) %>%
  rename("Cutoff" = Threshold) %>%
  mutate(across(where(is.numeric), ~round(.x, 3))) %>%
  flextable() %>% bold(part = "header") %>% bold(j = 1)

# ── 7. DeLong Test ────────────────────────────────────────────────────────────
# Compare the two AUCs using DeLong's method to test whether
# diagnostic performance differs significantly between predictors
roc.test(roc_gbwt, roc_ratio)

# ── 8. ROC Curve Plot ─────────────────────────────────────────────────────────
# Overlay ROC curves for both predictors; reference diagonal represents
# a non-informative classifier (AUC = 0.5)
ggroc(
  list(
    "GBWT (mm)" = roc_gbwt,
    "Platelet/spleen ratio" = roc_ratio
  ),
  legacy.axes = TRUE   # x-axis as (1 - Specificity) instead of Specificity
) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  coord_equal() +
  labs(
    x = "1 − Specificity",
    y = "Sensitivity",
    color = "Predictor"
  ) +
  theme_classic(base_size = 12)

