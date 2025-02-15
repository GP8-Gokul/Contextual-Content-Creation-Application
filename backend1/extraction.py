import io
import os
from PyPDF2 import PdfReader
from PyPDF2.errors import PdfReadError
from PIL import Image

OUTPUT_DIRECTORY = 'output'

def extract_content(pdf_bytes, keywords):
    # Wrap bytes in a BytesIO object for PdfReader
    pdf_stream = io.BytesIO(pdf_bytes)
    reader = PdfReader(pdf_stream)

    content = ""
    images_saved = 0

    # Iterate through all pages
    for page_num, page in enumerate(reader.pages):
        content += page.extract_text() or ""

        # Extract images with error handling
        try:
            if "/Resources" in page and "/XObject" in page["/Resources"]:
                xObject = page["/Resources"]["/XObject"].get_object()
                for obj_name in xObject:
                    obj = xObject[obj_name]
                    if obj["/Subtype"] == "/Image":
                        width = obj["/Width"]
                        height = obj["/Height"]
                        try:
                            data = obj.get_data()  # May raise PdfReadError

                            # Use Pillow to process the image
                            image = Image.open(io.BytesIO(data))
                            image = image.convert("RGB")  # Ensure compatibility

                            # Save the image
                            os.makedirs(OUTPUT_DIRECTORY, exist_ok=True)
                            image_path = os.path.join(OUTPUT_DIRECTORY, f'image_page{page_num}_{images_saved}.png')
                            image.save(image_path)
                            images_saved += 1
                        except PdfReadError as e:
                            print(f"Skipping problematic image on page {page_num}: {e}")
                        except Exception as e:
                            print(f"Error processing image on page {page_num}: {e}")
        except KeyError:
            print(f"No images found on page {page_num}")

    # Create output directory if it doesn't exist
    os.makedirs(OUTPUT_DIRECTORY, exist_ok=True)

    # Save text content
    text_path = os.path.join(OUTPUT_DIRECTORY, 'content.txt')
    with open(text_path, 'w', encoding='utf-8') as text_file:
        text_file.write(content)

    # Match keywords in the content
    matched_keywords = [kw for kw in keywords if kw in content]

    return {"matched_keywords": matched_keywords, "content_path": text_path, "images_saved": images_saved}
