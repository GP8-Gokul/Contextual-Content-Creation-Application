import fitz
import io
from PIL import Image
import re
import pdfplumber as pdfp

def extract_images_and_text_from_pdf(pdf_path, output_folder):
    try:
        with pdfp.open(pdf_path) as pdf:
            full_text = ""
            for page in pdf.pages:
                full_text += page.extract_text() + "\n"
        cleaned_text = full_text.encode("ascii", "ignore").decode("utf-8")
        cleaned_text = re.sub(r"[^a-zA-Z0-9\s.,!?'-]", " ", cleaned_text)
        cleaned_text = cleaned_text.strip()
        print(cleaned_text)
        with open("extracted_text.txt", "w", encoding="utf-8") as text_file:
            text_file.write(cleaned_text)

        pdf_document = fitz.open(pdf_path)
        for page_number in range(len(pdf_document)):
            page = pdf_document[page_number]
            images = page.get_images(full=True)

            print(f"Found {len(images)} images on page {page_number + 1}")

            for img_index, img in enumerate(images):
                xref = img[0]

                base_image = pdf_document.extract_image(xref)
                image_bytes = base_image["image"]
                image_ext = base_image["ext"]
                image = Image.open(io.BytesIO(image_bytes))
                image_path = f"{output_folder}/page_{page_number + 1}_image_{img_index + 1}.{image_ext}"
                image.save(image_path)

                print(f"Image saved: {image_path}")

        print("All images extracted successfully.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    pdf_path = "g:/projects/mini project/Contextual-Content-Creation-Application-/backend/pdf_to_text/testfile.pdf"
    output_folder = "g:/projects/mini project/Contextual-Content-Creation-Application-/images"
    extract_images_and_text_from_pdf(pdf_path, output_folder)
