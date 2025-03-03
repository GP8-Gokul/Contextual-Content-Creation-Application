import PyPDF2
import io
from PyPDF2 import PdfReader, PdfWriter
import json
import base64

def read_pdf(file_path, keywords):
    """ Reads the PDF and finds pages containing each keyword. """
    reader = PdfReader(file_path)
    num_pages = len(reader.pages)
    keyword_pages = {keyword: [] for keyword in keywords}

    for page_num in range(num_pages):
        page = reader.pages[page_num]
        content = page.extract_text() or ""  # Handle cases where text extraction fails
        for keyword in keywords:
            if keyword.lower() in content.lower():
                keyword_pages[keyword].append(page_num)

    return keyword_pages

def create_pdf_blob(input_pdf, keyword, pages):
    """ Creates a PDF containing only the specified pages and returns it as a binary blob. """
    reader = PdfReader(input_pdf)
    writer = PdfWriter()

    for page_num in pages:
        writer.add_page(reader.pages[page_num])

    # Store PDF in memory as a binary blob
    pdf_blob = io.BytesIO()
    writer.write(pdf_blob)
    pdf_blob.seek(0)  # Move to the start of the buffer

    return pdf_blob

# Define keywords
keywords = ['corrosion', 'combination reaction']

# Read PDF and find keyword occurrences
keyword_pages = read_pdf('interim/testfile.pdf', keywords)

# Dictionary to store keyword-based PDF blobs
pdf_blobs = {}

# Create separate PDFs for each keyword and store as blobs
for keyword, pages in keyword_pages.items():
    if pages:
        pdf_blob = create_pdf_blob('interim/testfile.pdf', keyword, pages)
        pdf_blobs[keyword] = base64.b64encode(pdf_blob.getvalue()).decode('utf-8')  # Store binary data as base64 string

# Save the pdf_blobs dictionary to a JSON file
with open('interim/pdf_blobs.json', 'w') as json_file:
    json.dump(pdf_blobs, json_file)

# Print confirmation
for keyword in pdf_blobs:
    print(f"PDF for keyword '{keyword}' created and stored as blob. Size: {len(pdf_blobs[keyword])} bytes")

# Print confirmation
for keyword in pdf_blobs:
    print(f"PDF for keyword '{keyword}' created and stored as blob. Size: {len(pdf_blobs[keyword])} bytes")
