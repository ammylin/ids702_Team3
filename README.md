# Global Happiness Analysis

**Authors:** Arvind Kandala, Ammy Lin, Lingyue Hao, Shelly Cao

![Status](https://img.shields.io/badge/Status-Complete-green)
![Language](https://img.shields.io/badge/Language-R-blue)
![Tool](https://img.shields.io/badge/Tool-Quarto-9cf)

## Project Overview
This project analyzes data from the **World Happiness Report (2015-2019)** to provide strategic recommendations to the **United Nations Development Programme (UNDP)**. 

Moving beyond simple correlations, this analysis uses interaction modeling to understand the **structural dependencies** of national well-being. The goal is to determine whether international aid should prioritize foundational economic/political stabilization or broader health/social programming in developing nations.

## Research Questions
1. **The "Survival Trap":** Is the relationship between life expectancy and national happiness dependent on a country's economic stability (GDP per capita)?
2. **Social Capital & Freedom:** Does the impact of generosity on regional happiness depend on the level of civil freedom within that region?

## Key Findings

### 1. Economic Stability is a Prerequisite Multiplier
Our linear regression analysis reveals a significant interaction between Life Expectancy and GDP. 
* **High GDP Nations:** Extending life expectancy significantly boosts national happiness.
* **Low GDP Nations:** Extending life expectancy yields **diminishing returns** on happiness.
* **Implication:** Health interventions in developing regions must be paired with economic safety nets to improve well-being.

### 2. Generosity is "Compensatory"
Our ordinal logistic regression shows that the relationship between generosity and happiness is conditional on freedom.
* **Low Freedom Regions:** Generosity has a massive positive impact on the likelihood of a region being "Happy."
* **High Freedom Regions:** The impact of generosity diminishes as freedom increases.
* **Implication:** Prosocial initiatives are most critical in restrictive political environments where citizens lack autonomy.

## Methodology & Tech Stack

**Language:** R  
**Framework:** Quarto (rendered to PDF via XeLaTeX)

### Models Used:
* **Multiple Linear Regression (OLS):** Assessed the Life Expectancy x GDP interaction. Used cluster-robust standard errors (clustered by country) to account for longitudinal dependence.
* **Ordinal Logistic Regression (Polr):** Assessed the Generosity x Freedom interaction on a categorized outcome (Low, Medium, High Happiness Groups).

### Key R Packages:
* **Data Manipulation:** `tidyverse`, `dplyr`, `tidyr`
* **Modeling:** `MASS` (Ordinal Logit), `lmtest`, `sandwich` (Robust SEs), `car`, `broom`
* **Visualization:** `ggplot2`, `ggeffects` (Interaction plots)
* **Reporting:** `knitr`, `kableExtra`

## How to Reproduce

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/lingyuehao/ids702_Team3.git](https://github.com/lingyuehao/ids702_Team3.git)
   ```

2. **Install required R packages:**

```
install.packages(c("tidyverse", "broom", "kableExtra", "ggplot2", 
                   "lmtest", "sandwich", "car", "MASS", "caret", "ggeffects"))
```

3. **Render the Report:** Open report.qmd in RStudio and click Render, or run the following command in your terminal:
```
quarto render report.qmd --to pdf
```

## Data Source
The data is sourced from the [World Happiness Report](https://www.kaggle.com/datasets/unsdsn/world-happiness) via Gallup World Poll, covering approximately 155 nations from 2015–2019.

## Project Deliverables
* **Final Report:** [View PDF](report.pdf)
* **Source Code:** [View Quarto File](report.qmd)

## Acknowledgements & Context
This project was developed as a final capstone for **IDS 702: Modeling and Representation of Data** at **Duke University** (Fall 2025). We would like to thank Professor Andrea Lane for her for her guidance and feedback throughout the development of this project. 