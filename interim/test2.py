import re
from pdfminer.high_level import extract_pages
from pdfminer.layout import LTTextBoxHorizontal, LTTextLineHorizontal

def clean_text(text):
    """Fixes duplicate words, broken words, and formatting issues."""
    lines = text.split("\n")
    cleaned_lines = []
    prev_words = set()  # Store previously seen words to remove duplicates

    for line in lines:
        line = line.strip()

        # Merge broken words (e.g., "EQUA\nTIONS" → "EQUATIONS")
        line = re.sub(r"(\w+)-?\n(\w+)", r"\1\2", line)

        # Remove duplicate words (e.g., "1.1 CHEMIC\n1.1 CHEMIC" → "1.1 CHEMIC")
        words = line.split()
        new_words = [w for w in words if w not in prev_words]
        
        if new_words:
            cleaned_line = " ".join(new_words)
            cleaned_lines.append(cleaned_line)
            prev_words.update(new_words)  # Store seen words

    return "\n\n".join(cleaned_lines)

def extract_text_best(pdf_path):
    """Extracts properly formatted text from a PDF using PDFMiner."""
    text = []
    seen_lines = set()

    for page_layout in extract_pages(pdf_path):
        for element in page_layout:
            if isinstance(element, (LTTextBoxHorizontal, LTTextLineHorizontal)):  
                line = element.get_text().strip()

                # Remove exact duplicate lines
                if line and line not in seen_lines:
                    seen_lines.add(line)
                    text.append(line)

    formatted_text = "\n\n".join(text)
    return clean_text(formatted_text)

# Run the function
pdf_path = "interim/testfile.pdf"
formatted_text = extract_text_best(pdf_path)

# Save output to a file
output_path = "interim/output2.txt"
with open(output_path, "w", encoding="utf-8") as file:
    file.write(formatted_text)

print(f"✅ Text extracted and saved to {output_path}")
