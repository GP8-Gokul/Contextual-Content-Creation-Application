import fitz 

def remove_images_and_vectors(input_pdf):
    doc = fitz.open(input_pdf)

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


def extract_and_sort_text(pdf_path):
    doc = remove_images_and_vectors(pdf_path)
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


def save_extracted_text(pdf_path, output_file_path):
    extracted_text = extract_and_sort_text(pdf_path)
    with open(output_file_path, "w", encoding="utf-8") as output_file:
        for pages in extracted_text:
            output_file.write("\n".join(pages))

if __name__ == "__main__":

    pdf_path = "interim/cgip.pdf"  
    output_file_path = "interim/extractedcgip.txt"  

    # Extract and save refined text
    save_extracted_text(pdf_path, output_file_path)
