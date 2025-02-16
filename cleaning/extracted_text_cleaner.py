import re

def remove_repeated_words(sentence):
    words = sentence.split()
    cleaned_words = []
    
    i = 0
    while i < len(words):
        cleaned_words.append(words[i])
        while i + 1 < len(words) and words[i] == words[i + 1]:  # Remove consecutive duplicate words
            i += 1
        i += 1

    return " ".join(cleaned_words)

def convert_numbers_and_symbols(text):
    subscript_map = str.maketrans("0123456789", "₀₁₂₃₄₅₆₇₈₉")  # Subscript conversion
    superscript_map = str.maketrans("0123456789+-", "⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻")  # Superscript conversion

    # Convert exponentiation notation (b^2 → b²)
    text = re.sub(r'\^(\d+)', lambda m: m.group(1).translate(superscript_map), text)

    # Convert ion charges (Na+, Cl-, H+, OH- → Na⁺, Cl⁻, H⁺, OH⁻)
    text = re.sub(r'([A-Za-z]+)([+-])', lambda m: m.group(1) + m.group(2).translate(superscript_map), text)

    # Convert numbers with + or - (Al3+ → Al³⁺, 3OH- → 3OH⁻)
    text = re.sub(r'([A-Za-z]+)(\d+)([+-])', lambda m: m.group(1) + m.group(2).translate(superscript_map) + m.group(3).translate(superscript_map), text)

    # Convert numbers after closing parentheses to subscript (OH)3 → (OH)₃
    text = re.sub(r'(\([A-Za-z]+\))(\d+)', lambda m: m.group(1) + m.group(2).translate(subscript_map), text)

    # Convert standalone numbers after elements to subscript (e.g., H2O → H₂O)
    text = re.sub(r'([A-Za-z])(\d+)', lambda m: m.group(1) + m.group(2).translate(subscript_map), text)

    return text

def process_text_list(text_list):
    cleaned_data = []  # Store cleaned [fontsize, text, is_bold]

    for item in text_list:
        fontsize, text, is_bold = item
        sentences = re.split(r'(?<=[.!?])\s+', text.strip())  # Split text into sentences

        cleaned_sentences = []
        seen_sentences = set()  # To track duplicates

        for sentence in sentences:
            if not sentence.strip():
                continue

            sentence = remove_repeated_words(sentence)  # Remove consecutive duplicate words
            sentence = convert_numbers_and_symbols(sentence)  # Convert numbers, +/-, and exponentiation
            
            # Ensure first letter is capitalized
            sentence = sentence[0].upper() + sentence[1:] if sentence else ""

            if sentence not in seen_sentences:  # Remove duplicate sentences
                seen_sentences.add(sentence)
                cleaned_sentences.append(sentence)

        cleaned_text = " ".join(cleaned_sentences)
        cleaned_data.append([fontsize, cleaned_text, is_bold])

    return cleaned_data

cleaned_list = process_text_list(text_list)
'''
for item in cleaned_list:
    print(item)
'''
