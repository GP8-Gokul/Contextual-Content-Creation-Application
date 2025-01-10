import fitz
import io
from PIL import Image, UnidentifiedImageError
import re
import pdfplumber as pdfp
import os
#bullshit
def clean_text_repeated_characters(text):
    """
    Removes excessive repeated characters caused by styled fonts (e.g., bold text).
    """
    return re.sub(r'(.)\1{2,}', r'\1', text)

def extract_images_and_text_from_pdf(pdf_path, text_output_folder, image_output_folder):
    try:
        with pdfp.open(pdf_path) as pdf:
            full_text = ""
            for page in pdf.pages:
                full_text += page.extract_text() + "\n"
        
        cleaned_text = full_text.encode("ascii", "ignore").decode("utf-8")
        cleaned_text = re.sub(r"[^a-zA-Z0-9\s.,!?'-]", " ", cleaned_text)
        cleaned_text = clean_text_repeated_characters(cleaned_text.strip())
        print("Cleaned Text:", cleaned_text)

        text_file_path = os.path.join(text_output_folder, "extracted_text.txt")
        with open(text_file_path, "w", encoding="utf-8") as text_file:
            text_file.write(cleaned_text)

        pdf_document = fitz.open(pdf_path)
        for page_number in range(len(pdf_document)):
            page = pdf_document[page_number]
            images = page.get_images(full=True)

            print(f"Found {len(images)} images on page {page_number + 1}")

            for img_index, img in enumerate(images):
                try:
                    xref = img[0]
                    base_image = pdf_document.extract_image(xref)
                    image_bytes = base_image["image"]
                    image_ext = base_image["ext"]

                    image = Image.open(io.BytesIO(image_bytes))
                    image_path = f"{image_output_folder}/page_{page_number + 1}_image_{img_index + 1}.{image_ext}"
                    image.save(image_path)
                    print(f"Image saved: {image_path}")
                except UnidentifiedImageError:
                    print(f"Skipped an invalid image on page {page_number + 1}, image {img_index + 1}.")
                except Exception as e:
                    print(f"An error occurred while saving an image: {e}")

        print("All text and images extracted successfully.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))

    pdf_path = os.path.join(script_dir, "testfile.pdf")
    text_output_folder = os.path.join(script_dir, "text")
    image_output_folder = os.path.join(script_dir, "images")

    os.makedirs(text_output_folder, exist_ok=True)
    os.makedirs(image_output_folder, exist_ok=True)

    extract_images_and_text_from_pdf(pdf_path, text_output_folder, image_output_folder)