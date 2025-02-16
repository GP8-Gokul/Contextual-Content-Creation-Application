from transformers import pipeline
import torch
import re
#from _ import data

device = "cuda" if torch.cuda.is_available() else "cpu"

try:
    classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")
except Exception as e:
    print(f"Error loading model: {e}")
    exit()

def classify_text(fontsize, text, is_bold):
    labels = ["This is a title or heading", "This is body text or content"]
    
    if is_bold:
        return "H"

    if re.search(r"[.?!]$", text):
        return "C"

    try:
        result = classifier(text, labels)
        return "H" if result["scores"][0] >= 0.75 else "C"
    except Exception as e:
        print(f"Error in classification: {e}")
        return "C"  # Default to content if classification fails

header_count = 0  # Counter for numbering headers
classified_data = []

try:
    if 'data' not in globals():
        raise NameError("Variable 'data' is not defined.")

    for fontsize, text, is_bold in data:
        classification = classify_text(fontsize, text, is_bold)

        entry = {
            "type": classification,
            "fsize": fontsize,
            "text": text
        }

        if classification == "H":
            header_count += 1
            entry["id"] = header_count

        classified_data.append(entry)

except Exception as e:
    print(f"Error processing data: {e}")

for item in classified_data:
    print(item)
