import re
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer

def search_top_percent_tfidf(text, keyword, top_percent=10):
    """Finds the top X% most relevant sentences based on TF-IDF scores."""
    
    # Split text into sentences
    sentences = re.split(r'(?<=\.)\s+|\n', text)  
    sentences = [s.strip() for s in sentences if s.strip()]  
    
    if not sentences:
        return "No content available."
    
    # Create TF-IDF vectorizer
    vectorizer = TfidfVectorizer(stop_words='english')
    
    # Fit and transform the sentences into TF-IDF vectors
    sentence_vectors = vectorizer.fit_transform(sentences)
    
    # Transform the keyword into the same vector space
    keyword_vector = vectorizer.transform([keyword])
    
    # Compute cosine similarity
    scores = (sentence_vectors @ keyword_vector.T).toarray().flatten()
    
    # Determine number of sentences to return
    num_sentences = max(1, int(len(sentences) * (top_percent / 100)))
    
    # Get top N most relevant sentences
    top_indices = np.argsort(scores)[-num_sentences:][::-1]
    
    # Retrieve the best matching sentences
    relevant_sentences = [sentences[i] for i in top_indices if scores[i] > 0]
    
    return "\n\n".join(relevant_sentences) if relevant_sentences else "Keyword not found."

# Read text from output2.txt
with open("interim/output2.txt", "r", encoding="utf-8") as file:
    extracted_text = file.read()

# Example usage
keyword = "Corrosion"
result = search_top_percent_tfidf(extracted_text, keyword, top_percent=10)
print(result)
