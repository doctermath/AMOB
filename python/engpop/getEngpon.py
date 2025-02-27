import requests
import pandas as pd

# Define URL
url = "http://172.16.5.6:8080/main/web/getengpop"

# Fetch data from the URL
response = requests.get(url)
response.raise_for_status()  # Raise error if request fails

data = response.json()  # Assuming the response is in JSON format

# Convert data to DataFrame
df = pd.DataFrame(data['data'])

# Export to Excel
df.to_excel("engpopdata.xlsx", index=False)

print("Data exported to engpopdata.xlsx successfully.")