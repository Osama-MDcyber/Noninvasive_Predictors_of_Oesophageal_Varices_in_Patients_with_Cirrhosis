# **Gall bladder wall thickening and platelet count-to-spleen diameter ratio as noninvasive predictors of oesophageal varices (OV) in patients with liver cirrhosis**

---

## Analysis Pipeline

1. **Data import & factor encoding**
2. **Table 1** — baseline characteristics stratified by variceal status
3. **ROC analysis** — curves built with `pROC`; AUC estimated for both
   predictors
4. **Optimal cutoffs** — Youden's index via `coords()`
5. **Performance table** — combined diagnostic metrics exported as a
   `flextable`
6. **DeLong's test** — formal AUC comparison between the two predictors
7. **ROC plot** — overlaid curves with `ggplot2`/`ggroc()`

---
