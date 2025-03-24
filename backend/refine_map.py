from sklearn.feature_extraction.text import TfidfVectorizer
import numpy as np

def refine_mapping(keyword_content, top_percent=40):
    refined_content = {}

    for keyword, content in keyword_content.items():
        if isinstance(content, list):  
            content = " ".join(content)  

        sentences = content.split(". ")
        if len(sentences) <= 3:  
            continue

        # TF-IDF Vectorizer for sentence importance
        vectorizer = TfidfVectorizer(stop_words="english")
        sentence_vectors = vectorizer.fit_transform(sentences)
        keyword_vector = vectorizer.transform([keyword])

        # Compute cosine similarity between keyword and sentences
        similarities = sentence_vectors.dot(keyword_vector.T).toarray().flatten()

        # Get top-ranked sentences
        num_sentences = max(1, int(len(sentences) * (top_percent / 100)))
        top_indices = np.argsort(similarities)[-num_sentences:][::-1]

        top_sentences = [sentences[i] for i in sorted(top_indices)]
        refined_content[keyword] = ". ".join(top_sentences)

    return refined_content
