import re
from pdfminer.high_level import extract_pages
from pdfminer.layout import LTTextBox, LTTextLine
from io import BytesIO

def clean_text(text):
    text = re.sub(r'(?m)^n\s+', '* ', text)  # `(?m)` makes `^` match start of each line

    text = re.sub(r'(^|\n)(.+)(\n\2)+', r'\1\2', text)  # Remove exact repeated lines

    text = re.sub(r'(\w+)-\n(\w+)', r'\1\2', text)  # Merge hyphenated words split at line breaks

    text = re.sub(r' {2,}', ' ', text)  # Reduce multiple spaces to a single space
    text = re.sub(r'\n{3,}', '\n\n', text)  # Limit excessive blank lines to max 2

    return text.strip()

def extract_text_best(pdf_path):
    text = []
    seen_lines = set()

    for page_layout in extract_pages(pdf_path):
        for element in page_layout:
            if isinstance(element, (LTTextBox, LTTextLine)):  
                line = element.get_text().strip()

               
                if line and line not in seen_lines:
                    seen_lines.add(line)
                    text.append(line)

    return clean_text("\n\n".join(text))

def extraction(pdf_bytes):
    pdf_stream = BytesIO(pdf_bytes)
    formatted_text = extract_text_best(pdf_stream)

    paragraphs = formatted_text.split('\n\n')

    filtered_paragraphs = []
    for paragraph in paragraphs:
        lines = paragraph.split('\n')
        filtered_lines = []
        for line in lines:
            if len(line) >= 6:
                filtered_lines.append(line)
        if filtered_lines:
            filtered_paragraphs.append('\n'.join(filtered_lines))

    paragraphs = filtered_paragraphs

    paragraphs_as_lines = [line for paragraph in paragraphs for line in paragraph.split('\n')]
    return paragraphs_as_lines

