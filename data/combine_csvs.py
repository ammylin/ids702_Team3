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

combined = combined.drop(
    columns=[
        "Family",
        "Trust (Government Corruption)",
        "Lower Confidence Interval",
        "Upper Confidence Interval",
        "Whisker.high",
        "Whisker.low",
        "Happiness Rank",
        "Standard Error",
        "Dystopia Residual",
    ],
    errors="ignore",
)

region_col = "Region"

region_map = (
    combined.dropna(subset=[region_col])
            .groupby("Country")[region_col]
            .agg(lambda x: x.mode().iat[0])
)

# Fill missing region values
missing_before = combined[region_col].isna().sum()
combined[region_col] = combined[region_col].fillna(combined["Country"].map(region_map))
missing_after = combined[region_col].isna().sum()

print(f"Missing '{region_col}' values after filling:  {missing_after}")

# Find countries where Region is still missing for all their observations
still_missing = combined[combined[region_col].isna()]
countries_needing_manual_region = sorted(still_missing["Country"].unique())

print("\nCountries with no region info in any year:")
for country in countries_needing_manual_region:
    print(country)

distinct_regions = sorted(combined[region_col].dropna().unique())

print("\ndistinct regions in the data:")
for r in distinct_regions:
    print(r)

manual_region_map = {
    "Gambia": "Sub-Saharan Africa",
    "Hong Kong S.A.R., China": "Eastern Asia",
    "North Macedonia": "Central and Eastern Europe",
    "Northern Cyprus": "Middle East and Northern Africa",
    "Taiwan Province of China": "Eastern Asia",
    "Trinidad & Tobago": "Latin America and Caribbean",
}

mask = combined["Country"].isin(manual_region_map.keys())
combined.loc[mask, region_col] = combined.loc[mask, "Country"].map(manual_region_map)

print("Missing region values after manual assignments:",
      combined[region_col].isna().sum())


out_path = Path("data") / "2015_2019_combined.csv"
combined.to_csv(out_path, index=False)

print(f"\nSaved combined file as {out_path}")