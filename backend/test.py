import requests
import base64

# Define the API endpoint
url = "http://127.0.0.1:5000/add"

# Read the PDF file and encode it as a base64 string
with open("interim/leph101.pdf", "rb") as pdf_file:
    pdf_base64 = base64.b64encode(pdf_file.read()).decode('utf-8')

# Sample data to send
data = {
    "pdf": pdf_base64,  # Sending PDF as base64 string
    "keywords": ["electric dipole", "conductor","quantisation"],
    "userid": 1
}

# Make a POST request
response = requests.post(url, json=data)

# Print the response
print("Status Code:", response.status_code)
print("Response JSON:", response.json())
