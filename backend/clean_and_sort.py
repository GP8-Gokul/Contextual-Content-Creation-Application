import fitz
import io

def remove_images_and_vectors(input_pdf):
    doc = doc = fitz.open(stream=input_pdf, filetype="pdf")

    for page_num in range(doc.page_count):
        page = doc.load_page(page_num)
        
        # Remove images and vector graphics
        images = page.get_images(full=True)
        for img in images:
            xref = img[0]
            page.delete_image(xref)
        
        # Remove vector graphics
        for item in page.get_drawings():
            if item["type"] in ["line", "rect", "curve", "polyline", "polygon"]:
                page.delete_drawing(item)

        # Clean the page contents
        page.clean_contents()

    return doc


def clean_and_sort(pdf_bytes):
    doc = remove_images_and_vectors(pdf_bytes)
    text_lines = []
    
    for page_num in range(doc.page_count):
        page = doc.load_page(page_num)
        blocks = page.get_text("blocks")

        sorted_blocks = sorted(blocks, key=lambda b: b[1])  # Sort by y0 (top position)

        page_text = ""
        for block in sorted_blocks:
            page_text += block[4].strip() + "\n"  # Append each block's text
        
        # Remove excessive line breaks for cleaner output
        page_text = "\n".join([line.strip() for line in page_text.splitlines() if line.strip()])

        # Store each line of the page text into a new list
        lines = page_text.split("\n")
        text_lines.append(lines)

    return text_lines