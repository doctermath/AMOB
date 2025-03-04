import sys
import json
import pandas as pd
import os

json_file = sys.argv[1]
excel_file = sys.argv[2]

with open(json_file, 'r') as f:
    data = json.load(f)
    
    df = pd.json_normalize(data['data'])
    df.to_excel(excel_file, index=False)

os.remove(json_file)
print('Excel File successfully created from JSON File at: ', excel_file)
