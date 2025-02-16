import torch
from transformers import pipeline
import re

def load_classifier():
    device = 0 if torch.cuda.is_available() else -1
    try:
        return pipeline("zero-shot-classification", model="facebook/bart-large-mnli", device=device)
    except Exception as e:
        print(f"Error loading model: {e}")
        return None

def is_related(classifier, text, keyword, threshold=0.75):
    try:
        result = classifier(text, [keyword])
        return result["scores"][0] >= threshold
    except Exception as e:
        print(f"Error in classification: {e}")
        return False

def extract_relevant_content(document_data, keywords):
    try:
        classifier = load_classifier()
        if classifier is None:
            return ""

        keyword_groups = {keyword: [] for keyword in keywords}  # Dictionary to store related texts per keyword
        i = 0
        while i < len(document_data):
            entry = document_data[i]
            text = entry["text"]
            related_keywords = []

            for keyword in keywords:
                if is_related(classifier, text, keyword):
                    related_keywords.append(keyword)

            if not related_keywords and i + 1 < len(document_data):
                combined_text = text + " " + document_data[i + 1]["text"]
                for keyword in keywords:
                    if is_related(classifier, combined_text, keyword):
                        related_keywords.append(keyword)
                        keyword_groups[keyword].append(entry)  # Append original entry
                        keyword_groups[keyword].append(document_data[i + 1])  # Append next entry
                        i += 1  # Skip next entry since it's already added
                        break

            for keyword in related_keywords:
                keyword_groups[keyword].append(entry)

            i += 1

        output = ""
        for keyword, entries in keyword_groups.items():
            if entries:
                output += f"{keyword} →\n"
                for entry in entries:
                    text = entry["text"]
                    if entry["type"] == "H":  # If it's a header, add a colon
                        output += f"{text}:\n"
                    else:
                        output += f"{text}\n"
                output += "\n"  # Extra line between keywords

        return output.strip()

    except Exception as e:
        print(f"Error in extract_relevant_content: {e}")
        return ""
'''
# Example Data
document_data = [
{'type': 'C', 'fsize': 10, 'text': 'onsider the following situations of daily life and think what happens. milk is left at room temperature during summers. an iron tawa/pan/nail is left exposed to humid atmosphere. food gets digested in our body. In all the above situations, the nature and the identity of the initial. substance have somewhat changed. We have already learnt about physical. and chemical changes of matter in our previous classes. change occurs, we can say that a chemical reaction has taken place. You may perhaps be wondering as to what is actually meant by a. How do we come to know that a chemical reaction. has taken place? Let us perform some activities to find the answer to'}
,{'type': 'H', 'fsize': 9, 'text': 'Burning of a magnesium ribbon in air and collection of magnesium. oxide in a watch-glass', 'id': 1}
,{'type': 'C', 'fsize': 10, 'text': 'would be better if students. Clean a magnesium ribbon. about 3-4 cm long by rubbing. Hold it with a pair of tongs. Burn it using a spirit lamp or. burner and collect the ash so. formed in a watch-glass as. magnesium ribbon keeping it. away as far as possible from. What do you observe?'}
,{'type': 'H', 'fsize': 10, 'text': '“Facts are not science — as the dictionary is not literature', 'id': 2}
,{'type': 'H', 'fsize': 9, 'text': 'gas by the action of. dilute sulphuric acid on', 'id': 3}
]

keywords = ["chemical equations", "law of mass"]
'''
formatted_output = extract_relevant_content(document_data, keywords)
#print(formatted_output)
