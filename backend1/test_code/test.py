import requests

# API endpoint
url = "http://127.0.0.1:5000/process"

# Path to the PDF file to be sent
pdf_path = "backend/test_code/testfile.pdf"  # Replace with the path to an actual PDF file

# Keywords to be sent
keywords = ["Flask", "API", "test"]

# Prepare the data payload
data = {
    "keywords": keywords
}

# Prepare the files payload
files = {
    "pdf_file": open(pdf_path, "rb")
}

# Send the POST request
response = requests.post(url, data=data, files=files)

# Check the response
if response.status_code == 200:
    print("Response received successfully!")
    print("Headers:", response.headers)
    # Save the received PDF (optional)
    with open("received_reference.pdf", "wb") as received_pdf:
        received_pdf.write(response.content)
    print("Received PDF saved as 'received_reference.pdf'.")
else:
    print(f"Error")

