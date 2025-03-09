from transformers import pipeline
import json

def keyword_content_mapping(chunks, keywords):
    keyword_content = {keyword: [] for keyword in keywords}
    classifier = pipeline("zero-shot-classification", model="MoritzLaurer/mDeBERTa-v3-base-mnli-xnli", device=0)

    for chunk in chunks:
        text = " ".join(chunk).strip()  
        if text:
            result = classifier(text, keywords, multi_label=True)
            for label, score in zip(result["labels"], result["scores"]):
                if score > 0.5:  
                    keyword_content[label].extend(chunk)

    return keyword_content

def main():
    
    keywords = ["corrosion", "combination reaction"]

    with open("interim/cleanedcgip.txt", "r", encoding="utf-8") as file:
        content = file.read().strip()
    
    chunks = [chunk.split("\n") for chunk in content.split("\n\n") if chunk.strip()]

    keyword_content = keyword_content_mapping(chunks, keywords)

    for keyword in keyword_content:
        keyword_content[keyword] = list(dict.fromkeys(keyword_content[keyword]))

    with open("interim/keyword_contentcgip.txt", "w", encoding="utf-8") as text_file:
        for keyword, texts in keyword_content.items():
            text_file.write(f"Keyword: {keyword}\n")
            for text in texts:
                text_file.write(f"{text}\n")
            text_file.write("\n")

    # Print results
    for keyword in keyword_content:
        keyword_content[keyword] = " ".join(keyword_content[keyword])

    with open("interim/keyword_contentcgip.json", "w", encoding="utf-8") as json_file:
        json.dump(keyword_content, json_file, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main()
