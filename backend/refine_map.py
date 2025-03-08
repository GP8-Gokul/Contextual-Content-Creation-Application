from transformers import pipeline

def initialize_summarizer():
    global summarizer
    summarizer = pipeline("summarization", model="facebook/bart-large-cnn")

def refine_mapping(keyword_content):
    for keyword, content in keyword_content.items():
        content = summarizer(content)
        keyword_content[keyword] = content
    return keyword_content