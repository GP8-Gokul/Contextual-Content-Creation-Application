import re
from pdfminer.high_level import extract_pages
from pdfminer.layout import LTTextBox, LTTextLine

def clean_text(text):
    """Cleans extracted text by removing unwanted duplicates, fixing formatting, and preserving structure."""
    
    # Replace 'n' at the beginning of lines with '* ' (bullet points)
    text = re.sub(r'(?m)^n\s+', '* ', text)  # `(?m)` makes `^` match start of each line

    # Remove repeated lines (headings, figure labels, activity names, etc.)
    text = re.sub(r'(^|\n)(.+)(\n\2)+', r'\1\2', text)  # Remove exact repeated lines
    
    # Fix words split across lines (common in PDFs with justified text)
    text = re.sub(r'(\w+)-\n(\w+)', r'\1\2', text)  # Merge hyphenated words split at line breaks
    
    # Normalize excessive spaces and newlines
    text = re.sub(r' {2,}', ' ', text)  # Reduce multiple spaces to a single space
    text = re.sub(r'\n{3,}', '\n\n', text)  # Limit excessive blank lines to max 2

    return text.strip()

def extract_text_best(pdf_path):
    """Extracts properly formatted text from any PDF while removing duplicates and fixing layout issues."""
    text = []
    seen_lines = set()

    for page_layout in extract_pages(pdf_path):
        for element in page_layout:
            if isinstance(element, (LTTextBox, LTTextLine)):  
                line = element.get_text().strip()

                # Avoid blank lines and exact duplicates
                if line and line not in seen_lines:
                    seen_lines.add(line)
                    text.append(line)

    return clean_text("\n\n".join(text))

# Run the function
pdf_path = "interim/testfile.pdf"
formatted_text = extract_text_best(pdf_path)

# Print or save output

# Split the formatted text into a list of paragraphs
paragraphs = formatted_text.split('\n\n')

# Filter out paragraphs with length less than 6
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

# Save each paragraph as a new element in the output file
with open("interim/output2.txt", "w") as file:
    for paragraph in paragraphs:
        file.write(paragraph + '\n\n')
    print("Text extracted and saved to output2.txt")

