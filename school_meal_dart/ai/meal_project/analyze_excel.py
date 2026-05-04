import pandas as pd
import sys

file_path = 'dinnerxlsx/202605.xlsx'

try:
    # Read the excel file, skipping no rows initially to see the raw layout
    df = pd.read_excel(file_path, header=None)
    
    print(f"Excel shape: {df.shape}")
    print("--- Top 15 rows ---")
    # Print the first 15 rows to understand the structure (dates, menus)
    for index, row in df.head(15).iterrows():
        row_str = " | ".join([str(val).replace('\n', ' ')[:20] for val in row])
        print(f"Row {index}: {row_str}")

except Exception as e:
    print(f"Error reading Excel: {e}")
    sys.exit(1)