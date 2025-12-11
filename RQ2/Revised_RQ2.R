---
  title: "Global Happiness Analysis"
subtitle: "Arvind Kandala, Ammy Lin, Lingyue Hao, Shelly Cao"
execute:
  echo: false
message: false
warning: false
editor: visual
format: pdf
---

library(MASS)
library(dplyr)
library(caret)
library(ggeffects)
library(knitr)
library(kableExtra)

happiness <- read.csv("https://github.com/lingyuehao/ids702_Team3/raw/refs/heads/main/data/2015_2019_combined_updated.csv")


happiness <- happiness %>%
  rename(
    country          = Country,
    region           = Region,
    score            = Happiness.Score,
    gdp_index        = Economy..GDP.per.Capita.,
    family_index     = Family,
    lifeexp_index    = Health..Life.Expectancy.,
    freedom_index    = Freedom,
    trust_index      = Trust..Government.Corruption.,
    generosity_index = Generosity,
    year             = Year
  )

happiness <- happiness %>%
  filter(
    !is.na(region),
    region != "",
    !is.na(score),
    !is.na(generosity_index),
    !is.na(freedom_index),
    !is.na(family_index),
    !is.na(trust_index),
    !is.na(lifeexp_index),
    !is.na(gdp_index),
    !is.na(year)
  )

region_avg <- happiness %>%
  group_by(region) %>%
  summarize(
    avg_happiness = mean(score, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    happy_group_num = ntile(avg_happiness, 3),
    Region_Happy_Group = case_when(
      happy_group_num == 1 ~ "Low",
      happy_group_num == 2 ~ "Medium",
      happy_group_num == 3 ~ "High"
    ),
    Region_Happy_Group = factor(
      Region_Happy_Group,
      levels = c("Low", "Medium", "High"),
      ordered = TRUE
    )
  )

happiness_ord <- happiness %>%
  left_join(
    region_avg %>% select(region, Region_Happy_Group),
    by = "region"
  ) %>%
  filter(!is.na(Region_Happy_Group))

rq2_model <- polr(
  Region_Happy_Group ~ 
    generosity_index * freedom_index +
    lifeexp_index +
    gdp_index +
    family_index +
    trust_index +
    freedom_index +
    generosity_index +
    year,
  data = happiness_ord,
  Hess = TRUE
)

summary(rq2_model)

ctable <- coef(summary(rq2_model))
p_vals <- pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2
ctable_with_p <- cbind(ctable, "p value" = p_vals)
ctable_with_p

exp_coefs <- exp(cbind(OR = coef(rq2_model), confint.default(rq2_model)))
exp_coefs


mf <- model.frame(rq2_model)
truth <- mf$Region_Happy_Group
pred_class <- predict(rq2_model)

truth <- factor(truth, levels = levels(truth))
pred_class <- factor(pred_class, levels = levels(truth))

confusionMatrix(pred_class, truth)

ggeffects::predict_response(
  rq2_model,
  terms = c("generosity_index [all]", "freedom_index")
) |>
  plot() +
  labs(
    title = "Predicted Probabilities of Regional Happiness Group",
    x = "Generosity Index",
    y = "Predicted Probability",
    color = "Freedom Index",
    fill  = "Freedom Index"
  ) +
  theme_bw(base_size = 14)


#############TABLE##############



## =========================
## 1. Summary Table 
## =========================

crit_val <- qnorm(0.975)

rq2_table <- data.frame(
  term      = rownames(ctable_with_p),
  estimate  = ctable_with_p[, "Value"],
  std.error = ctable_with_p[, "Std. Error"],
  statistic = ctable_with_p[, "t value"],
  p.value   = ctable_with_p[, "p value"],
  stringsAsFactors = FALSE
) %>%
  mutate(
    conf.low  = estimate - crit_val * std.error,
    conf.high = estimate + crit_val * std.error
  ) %>%
  mutate(
    term = dplyr::recode(
      term,
      "generosity_index"               = "Generosity index",
      "freedom_index"                  = "Freedom index",
      "lifeexp_index"                  = "Life expectancy index",
      "gdp_index"                      = "GDP per capita index",
      "family_index"                   = "Family index",
      "trust_index"                    = "Trust index",
      "year"                           = "Year",
      "generosity_index:freedom_index" = "Generosity × Freedom",
      "Low|Medium"                     = "Cutpoint: Low | Medium",
      "Medium|High"                    = "Cutpoint: Medium | High"
    ),
    p.value   = ifelse(p.value < 0.001, "<0.001",
                       sprintf("%.3f", round(p.value, 3))),
    estimate  = sprintf("%.3f", round(estimate, 3)),
    std.error = sprintf("%.3f", round(std.error, 3)),
    statistic = sprintf("%.3f", round(statistic, 3)),
    conf.low  = sprintf("%.3f", round(conf.low, 3)),
    conf.high = sprintf("%.3f", round(conf.high, 3))
  )

colnames(rq2_table) <- c(
  "Variable", "Estimate", "Std Error", "t-value", "p-value",
  "2.5% CI", "97.5% CI"
)

rownames(rq2_table) <- NULL

kable(
  rq2_table,
  caption = "Ordinal logistic regression model for regional happiness group",
  booktabs = TRUE,
  longtable = FALSE,
  linesep  = "",
  align    = c("l", "c", "c", "c", "c", "c", "c")
) %>%
  kable_styling(full_width = FALSE, font_size = 10)


## =========================
## 2. Odds Ratio Table
## =========================

rq2_or_df <- data.frame(
  term     = rownames(exp_coefs),
  OR       = exp_coefs[, "OR"],
  conf.low = exp_coefs[, "2.5 %"],
  conf.high= exp_coefs[, "97.5 %"],
  stringsAsFactors = FALSE
)

# Match p-values to the same terms (no cutpoints)
p_df <- data.frame(
  term    = rownames(ctable_with_p),
  p.value = ctable_with_p[, "p value"],
  stringsAsFactors = FALSE
) %>%
  filter(term %in% rq2_or_df$term)

rq2_or_table <- rq2_or_df %>%
  left_join(p_df, by = "term") %>%
  mutate(
    term = dplyr::recode(
      term,
      "generosity_index"               = "Generosity index",
      "freedom_index"                  = "Freedom index",
      "lifeexp_index"                  = "Life expectancy index",
      "gdp_index"                      = "GDP per capita index",
      "family_index"                   = "Family index",
      "trust_index"                    = "Trust index",
      "year"                           = "Year",
      "generosity_index:freedom_index" = "Generosity × Freedom"
    ),
    p.value  = ifelse(p.value < 0.001, "<0.001",
                      sprintf("%.3f", round(p.value, 3))),
    OR       = sprintf("%.3f", round(OR, 3)),
    conf.low = sprintf("%.3f", round(conf.low, 3)),
    conf.high= sprintf("%.3f", round(conf.high, 3))
  )

colnames(rq2_or_table) <- c(
  "Variable", "Odds Ratio", "2.5% CI", "97.5% CI", "p-value"
)

rownames(rq2_or_table) <- NULL

kable(
  rq2_or_table,
  caption = "Odds ratios from ordinal logistic regression for regional happiness group",
  booktabs = TRUE,
  longtable = FALSE,
  linesep  = "",
  align    = c("l", "c", "c", "c", "c")
) %>%
  kable_styling(full_width = FALSE, font_size = 10)


## =========================
## 3. Confusion Matrix Table
## =========================
mf <- model.frame(rq2_model)
truth <- mf$Region_Happy_Group
pred_class <- predict(rq2_model)

truth <- factor(truth, levels = levels(truth))
pred_class <- factor(pred_class, levels = levels(truth))

cm <- confusionMatrix(pred_class, truth)
cm_counts <- as.data.frame.matrix(cm$table)

cm_table <- cm_counts %>%
  mutate(Prediction = rownames(cm_counts)) %>%
  select(Prediction, Low, Medium, High)

kable(
  cm_table,
  caption = "Confusion Matrix for Ordinal Logistic Regression (Regional Happiness Group)",
  booktabs = TRUE,
  align = c("l", "c", "c", "c")
) %>%
  kable_styling(full_width = FALSE, font_size = 10)
