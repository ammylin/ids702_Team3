library(MASS)
library(dplyr)
library(caret) 
library(ggeffects)

df <- read.csv("https://github.com/lingyuehao/ids702_Team3/raw/refs/heads/main/data/2015_2019_combined.csv")

df_clean <- df %>%
  filter(
    !is.na(Region),
    Region != "",
    !is.na(Generosity),
    !is.na(Freedom)
  )

# Regional average happiness
region_avg <- df_clean %>%
  group_by(Region) %>%
  summarize(
    avg_happiness = mean(Happiness.Score, na.rm = TRUE),
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

# Join back to main data
df2 <- df_clean %>%
  left_join(
    region_avg %>% dplyr::select(Region, Region_Happy_Group),
    by = "Region"
  ) %>%
  filter(!is.na(Region_Happy_Group))

# model 
model2 <- polr(
  Region_Happy_Group ~ Generosity * Freedom,   # removed Year
  data = df2,
  Hess = TRUE
)
summary(model2)

# Add p-values
ctable <- coef(summary(model2))
p_vals <- pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2
ctable_with_p <- cbind(ctable, "p value" = p_vals)
ctable_with_p

# Odds ratios with CI
exp_coefs <- exp(cbind(OR = coef(model2), confint.default(model2)))
exp_coefs

# Assess the accuracy of the predictions
mf <- model.frame(model2)       
truth <- mf$Region_Happy_Group       
pred_class <- predict(model2)   

truth <- factor(truth, levels = levels(truth))
pred_class <- factor(pred_class, levels = levels(truth))

confusionMatrix(pred_class, truth)

# simple visualization
ggeffects::predict_response(model2, terms = c("Generosity [all]", "Freedom")) |> 
  plot()
