import re
import pdfplumber as pdfp
import os

def clean_text_repeated_characters(text):
    """
    Removes excessive repeated characters caused by styled fonts (e.g., bold text).
    """
    return re.sub(r'(.)\1{2,}', r'\1', text)

def extract_images_and_text_from_pdf(pdf_path, text_output_folder):
    try:
        with pdfp.open(pdf_path) as pdf:
            full_text = ""
            for page in pdf.pages:
                full_text += page.extract_text() + "\nPage Ends Here\n"
        
        cleaned_text = full_text.encode("ascii", "ignore").decode("utf-8")
        cleaned_text = re.sub(r"[^a-zA-Z0-9\s.,!?'-]", " ", cleaned_text)
        cleaned_text = clean_text_repeated_characters(cleaned_text.strip())
        print("Cleaned Text:", cleaned_text)

        pdf_name = os.path.splitext(os.path.basename(pdf_path))[0]
        text_file_path = os.path.join(text_output_folder, f"{pdf_name}.txt")

        with open(text_file_path, "w", encoding="utf-8") as text_file:
            text_file.write(cleaned_text)
        print(f"Extracted text saved to: {text_file_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))

    pdf_path = os.path.join(script_dir, "testfile.pdf")
    text_output_folder = os.path.join(script_dir, "text")

    os.makedirs(text_output_folder, exist_ok=True)

    extract_images_and_text_from_pdf(pdf_path, text_output_folder)
