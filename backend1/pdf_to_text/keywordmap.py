from transformers import AutoTokenizer, AutoModel
import os
import torch
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
import nltk

# Download NLTK stopwords
nltk.download("stopwords")
nltk.download("punkt")

# Load the BERT model and tokenizer for embeddings
bert_model_name = "bert-base-uncased"
bert_tokenizer = AutoTokenizer.from_pretrained(bert_model_name)
bert_model = AutoModel.from_pretrained(bert_model_name)

def load_text_file(file_path):
    """Loads text from a file."""
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read()

def get_bert_embeddings(text):
    """
    Generates BERT embeddings for a given text.

    Args:
        text (str): Input text.

    Returns:
        torch.Tensor: Embeddings for the input text.
    """
    inputs = bert_tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512)
    with torch.no_grad():
        outputs = bert_model(**inputs)
    return outputs.last_hidden_state.mean(dim=1)  # Average the embeddings across tokens

def extract_keywords(text, top_n=10):
    """
    Extracts keywords from the text using cosine similarity between word and document embeddings.

    Args:
        text (str): Input text from which to extract keywords.
        top_n (int): Number of top keywords to extract.

    Returns:
        list: A list of top-n keywords.
    """
    stop_words = set(stopwords.words("english"))
    words = word_tokenize(text)
    words = [word for word in words if word.isalnum() and word.lower() not in stop_words]

    # Compute BERT embeddings for the document
    doc_embedding = get_bert_embeddings(text).numpy()

    # Compute BERT embeddings for each word
    word_embeddings = {word: get_bert_embeddings(word).numpy() for word in set(words)}

    # Compute cosine similarity between document and each word
    similarities = {
        word: cosine_similarity(doc_embedding, embedding)[0][0]
        for word, embedding in word_embeddings.items()
    }

    # Sort words by similarity and return the top N
    sorted_keywords = sorted(similarities.items(), key=lambda x: x[1], reverse=True)
    return [word for word, _ in sorted_keywords[:top_n]]

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    text_folder = os.path.join(script_dir, "text")
    input_file = os.path.join(text_folder, "testfile.txt")
    input_text = load_text_file(input_file)

    # Extract keywords
    keywords = extract_keywords(input_text, top_n=10)
    print(f"Extracted Keywords: {keywords}")

if __name__ == "__main__":
    main()
