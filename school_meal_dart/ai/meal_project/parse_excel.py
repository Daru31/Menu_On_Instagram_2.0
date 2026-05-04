import sys
import pandas as pd
import re

def clean_menu(text):
    if pd.isna(text):
        return ""
    text = str(text)
    # Remove things in parentheses (allergy info)
    text = re.sub(r'\([^)]*\)', '', text)
    # Split by newline, strip spaces, remove empty lines
    lines = [line.strip() for line in text.split('\n') if line.strip()]
    return '\n'.join(lines)

def get_menu_for_day(file_path, target_day):
    target_day = str(target_day)
    try:
        df = pd.read_excel(file_path, header=None)
        
        # Iterate over all rows and columns to find the cell containing the target day
        # In a calendar layout, dates are usually alone in a cell or start with the number.
        for r_idx, row in df.iterrows():
            for c_idx, val in enumerate(row):
                if pd.isna(val):
                    continue
                
                # Check if the cell exactly matches the day or starts with it (e.g. "4", "4일")
                cell_str = str(val).strip()
                # School calendars often have just the number, or sometimes "4(수)"
                if cell_str == target_day or cell_str.startswith(f"{target_day}(") or cell_str.startswith(f"{target_day} "):
                    # Found the date! The menu is usually in the cell directly below it.
                    # Or sometimes 2 cells below if there are calories in between. 
                    # Let's check the next few rows in the same column for the longest text.
                    menu_text = ""
                    for offset in range(1, 4):
                        if r_idx + offset < len(df):
                            next_cell_val = df.iloc[r_idx + offset, c_idx]
                            if pd.notna(next_cell_val):
                                cleaned = clean_menu(next_cell_val)
                                if len(cleaned) > len(menu_text):
                                    menu_text = cleaned
                    
                    if menu_text:
                        print(menu_text)
                        return
                    
        print("Menu not found for the specified day.")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python parse_excel.py <file_path> <day>")
        sys.exit(1)
        
    file_path = sys.argv[1]
    day = sys.argv[2]
    get_menu_for_day(file_path, day)
