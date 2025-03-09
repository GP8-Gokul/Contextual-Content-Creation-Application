import requests
import json
import base64

# Define the API endpoint
url = "http://127.0.0.1:5000/studyplan"

data = {
    "user_id": 1,
    "s_id": 1
}

# Make a POST request
response = requests.post(url, json=data)

# Print the response
print("Status Code:", response.status_code)
# Write the response JSON to a file
with open('backend/final.json', 'w') as f:
    json.dump(response.json(), f, indent=4)

