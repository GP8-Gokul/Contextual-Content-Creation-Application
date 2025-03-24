from transformers import pipeline, AutoTokenizer

def initialize_summarizer():
    global summarizer, tokenizer
    summarizer = pipeline("summarization", model="facebook/bart-large-cnn")
    tokenizer = AutoTokenizer.from_pretrained("facebook/bart-large-cnn")

def refine_mapping(keyword_content, num_paragraphs=3, max_tokens=512):
    refined_content = {}

    for keyword, content in keyword_content.items():
        if isinstance(content, list):
            content = " ".join(content)

        paragraphs = [para.strip() for para in content.split("\n") if len(para.strip()) > 5]
        relevant_paragraphs = [para for para in paragraphs if keyword.lower() in para.lower()]

        if not relevant_paragraphs:
            continue

        chunks = [" ".join(relevant_paragraphs[i:i + num_paragraphs]) for i in range(0, len(relevant_paragraphs), num_paragraphs)]
        summaries = [summarizer(chunk, max_length=max_tokens, min_length=50, do_sample=False)[0]["summary_text"]
                     for chunk in chunks if len(tokenizer.encode(chunk, add_special_tokens=False)) >= 50]

        refined_content[keyword] = " ".join(summaries)

    return refined_content
