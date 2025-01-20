import re

def clean_text(text, max_line_length=80):
    cleaned_lines = []
    i = 0

    while i < len(text):
        line = text[i].strip()  # Remove leading/trailing whitespace

        # Check for repeating lines
        repeat_count = 1
        while i + repeat_count < len(text) and text[i + repeat_count].strip() == line:
            repeat_count += 1

        if repeat_count > 1:
            # Skip all repeated lines
            i += repeat_count
            continue

        # Cleaning logic for non-repeating lines
        if len(line) < 4:
            i += 1
            continue
        if line.isupper():
            i += 1
            continue
        if 'activity' in line.lower() or 'figure' in line.lower():
            if len(line) < 10:
                i += 1
                continue
        if re.fullmatch(r'[A-Z0-9.]+', line) and len(line) < 10:
            i += 1
            continue
        if re.fullmatch(r'[\d\W]+', line):
            i += 1
            continue

        # Add the cleaned line to the result
        cleaned_lines.append(line)
        i += 1

    # Combine short lines with the next line, except for equations or formatted structures
    combined_lines = []
    buffer = ""

    for line in cleaned_lines:
        # Detect patterns that shouldn't be combined (e.g., equations or formatted lines)
        if re.search(r'||Heat|[A-Za-z]\d|\(|\)', line):  # Detect chemical equations or structured lines
            if buffer:  # If there's a buffered line, finalize it
                combined_lines.append(buffer.strip())
                buffer = ""
            combined_lines.append(line.strip())  # Add the line directly
            continue

        if buffer:  # If buffer is not empty, try to combine
            potential_combination = f"{buffer} {line}"
            if len(potential_combination) <= max_line_length:
                buffer = potential_combination
            else:
                combined_lines.append(buffer.strip())
                buffer = line
        else:
            buffer = line

    # Add any remaining buffer to combined lines
    if buffer.strip():
        combined_lines.append(buffer.strip())

    return combined_lines
