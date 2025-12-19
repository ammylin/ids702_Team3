import pandas as pd
from pathlib import Path

csv_path = Path("data") / "2015_2019_combined.csv"

df = pd.read_csv(csv_path)

country_counts = df["Country"].value_counts()

print("Counts for each country:")
print(country_counts)

not_five = [(country, int(count)) 
            for country, count in country_counts.items() 
            if count != 5]

print("\nCountries that do NOT occur 5 times:")
for country, count in not_five:
    print(f"{country}: {count}")

print("total # of countries that don't occur 5 times: ", len(not_five))
missing_mask = df.isna().any(axis=1) 
num_missing = missing_mask.sum()
total_rows = len(df)

print(f"Rows with at least 1 missing value: {num_missing} out of {total_rows}")
rows_with_missing = df[missing_mask]
print("\nRows with missing values:")
print(rows_with_missing)