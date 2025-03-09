from transformers import pipeline, AutoTokenizer

def initialize_summarizer():
    global summarizer, tokenizer
    summarizer = pipeline("summarization", model="facebook/bart-large-cnn")
    tokenizer = AutoTokenizer.from_pretrained("facebook/bart-large-cnn")

def chunk_text(text, max_tokens=1000):
    tokens = tokenizer.encode(text, add_special_tokens=False)  
    chunks = [tokens[i:i + max_tokens] for i in range(0, len(tokens), max_tokens)]

    return [tokenizer.decode(chunk, skip_special_tokens=True) for chunk in chunks]  

def refine_mapping(keyword_content):
    for keyword, content in keyword_content.items():
        chunks = chunk_text(content, max_tokens=1000)
        summaries = [summarizer(chunk)[0]['summary_text'] for chunk in chunks]
        keyword_content[keyword] = " ".join(summaries)  
    return keyword_content
