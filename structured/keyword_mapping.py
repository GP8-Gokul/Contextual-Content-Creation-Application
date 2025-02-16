import torch
from transformers import pipeline
import re
#from _ import keywords

def load_classifier():
    device = 0 if torch.cuda.is_available() else -1
    try:
        return pipeline("zero-shot-classification", model="facebook/bart-large-mnli", device=device)
    except Exception as e:
        print(f"Error loading model: {e}")
        return None

def is_related(classifier, text, keyword, threshold=0.75, fallback_threshold=0.6):
    try:
        result = classifier(text, [keyword])
        return result["scores"][0] >= threshold or result["scores"][0] >= fallback_threshold
    except Exception as e:
        print(f"Error in classification: {e}")
        return False

def extract_relevant_content(document_data, keywords):
    try:
        classifier = load_classifier()
        if classifier is None:
            return []

        keyword_groups = {keyword: [] for keyword in keywords}  # Dictionary to store related texts per keyword
        i = 0
        while i < len(document_data):
            entry = document_data[i]
            text = entry["text"]
            matched_keywords = []

            for keyword in keywords:
                if is_related(classifier, text, keyword):
                    matched_keywords.append(keyword)

            if not matched_keywords and i + 1 < len(document_data):
                combined_text = text + ": " + document_data[i + 1]["text"]
                for keyword in keywords:
                    if is_related(classifier, combined_text, keyword):
                        matched_keywords.append(keyword)
                        keyword_groups[keyword].append(entry)  # Append original text
                        keyword_groups[keyword].append(document_data[i + 1])  # Append next text
                        i += 1  # Skip next entry since it's already added
                        break
            
            for keyword in matched_keywords:
                keyword_groups[keyword].append(entry)
            
            i += 1

        return [ [keyword] + texts for keyword, texts in keyword_groups.items() if texts ]
    
    except Exception as e:
        print(f"Error in extract_relevant_content: {e}")
        return []

filtered_content = extract_relevant_content(document_data, keywords)
'''
import pprint
pprint.pprint(filtered_content)
'''
