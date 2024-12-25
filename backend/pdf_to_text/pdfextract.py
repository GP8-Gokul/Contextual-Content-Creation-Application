import pdfplumber as pdfp
import re

def extract_text_from_pdf(pdf_path):
    try:
        with pdfp.open(pdf_path) as pdf:
            full_text = ""
            for page in pdf.pages:
                full_text += page.extract_text() + "\n"
        cleaned_text = full_text.encode("ascii", "ignore").decode("utf-8")
        cleaned_text = re.sub(r"[^a-zA-Z0-9\s.,!?'-]", " ", cleaned_text)
        cleaned_text = cleaned_text.strip()
        
        print(cleaned_text)
    except Exception as e:
        print(e)

#Use your own path. The pdf is provided in the file. :)
pdf_path = input("Enter the full path to the PDF file: ")
extract_text_from_pdf(pdf_path)