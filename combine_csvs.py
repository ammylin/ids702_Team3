import pandas as pd
from pathlib import Path

# rename the columns to standardized
column_renames = {
    2015: {
        # keep format same
    },
    2016: {
        # keep format same
    },
    2017: {
        "Happiness.Rank": "Happiness Rank",
        "Happiness.Score": "Happiness Score",
        "Economy..GDP.per.Capita.": "Economy (GDP per Capita)",
        "Health..Life.Expectancy.": "Health (Life Expectancy)",
        "Trust..Government.Corruption.": "Trust (Government Corruption)",
        "Dystopia.Residual": "Dystopia Residual",
    },
    2018: {
        "Overall rank": "Happiness Rank",
        "Country or region": "Country",
        "Score": "Happiness Score",
        "GDP per capita": "Economy (GDP per Capita)",
        "Social support": "Family",
        "Healthy life expectancy": "Health (Life Expectancy)",
        "Freedom to make life choices": "Freedom",
        "Perceptions of corruption": "Trust (Government Corruption)",
    },
    2019: {
        "Overall rank": "Happiness Rank",
        "Country or region": "Country",
        "Score": "Happiness Score",
        "GDP per capita": "Economy (GDP per Capita)",
        "Social support": "Family",
        "Healthy life expectancy": "Health (Life Expectancy)",
        "Freedom to make life choices": "Freedom",
        "Perceptions of corruption": "Trust (Government Corruption)",
    },
}

dfs = []

for year in range(2015, 2020):
    file_path = Path("data") / f"{year}.csv"
    df_year = pd.read_csv(file_path)

    df_year = df_year.rename(columns=column_renames.get(year))

    df_year["Year"] = year

    dfs.append(df_year)

combined = pd.concat(dfs, ignore_index=True)

combined = combined.drop(columns=["Family", "Trust (Government Corruption)", 
                                  "Lower Confidence Interval", "Upper Confidence Interval", "Whisker.high", "Whisker.low","Happiness Rank", "Standard Error", "Dystopia Residual", "Region"], errors="ignore")

out_path = Path("data") / "2015_2019_combined.csv"
combined.to_csv(out_path, index=False)

print(f"Saved combined file as {out_path}")
