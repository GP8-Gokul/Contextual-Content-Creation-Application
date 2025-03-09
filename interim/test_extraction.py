from pdfminer.high_level import extract_pages
from pdfminer.layout import LTTextBox, LTTextLine

def extract_text_best(pdf_path):
    """Extracts properly formatted text from a PDF using PDFMiner."""
    text = []
    seen_lines = set()

    for page_layout in extract_pages(pdf_path):
        for element in page_layout:
            if isinstance(element, (LTTextBox, LTTextLine)):  # Extract only text elements
                line = element.get_text().strip()

                # Remove empty lines & duplicates
                if line and line not in seen_lines:
                    seen_lines.add(line)
                    text.append(line)

    return "\n\n".join(text)

# Run the function
pdf_path = "interim/testfile.pdf"
formatted_text = extract_text_best(pdf_path)

# Print or save output

with open("interim/output.txt", "w") as file:
    file.write(formatted_text)
    print("Text extracted and saved to output.txt")
