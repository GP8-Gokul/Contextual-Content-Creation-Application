from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def extract_relevant_paragraphs_with_neighbors(paragraphs, keyword, threshold=0.8, neighbor_threshold=0.5):
    # Load pre-trained BERT-based model
    model = SentenceTransformer("all-MiniLM-L6-v2")  # Small, efficient transformer

    # Compute embeddings for all paragraphs
    paragraph_embeddings = model.encode(paragraphs, convert_to_numpy=True)

    # Compute embedding for the keyword query
    keyword_embedding = model.encode([keyword], convert_to_numpy=True)

    # Compute cosine similarity between keyword and each paragraph
    similarities = cosine_similarity(keyword_embedding, paragraph_embeddings)[0]

    selected_indices = set()

    # Select paragraphs based on main threshold
    for i, score in enumerate(similarities):
        if score > threshold:
            selected_indices.add(i)
            # Check previous and next paragraphs with a lower threshold
            if i > 0 and similarities[i - 1] > neighbor_threshold:
                selected_indices.add(i - 1)
            if i < len(paragraphs) - 1 and similarities[i + 1] > neighbor_threshold:
                selected_indices.add(i + 1)

    # Extract selected paragraphs
    relevant_paragraphs = [paragraphs[i] for i in sorted(selected_indices)]

    return relevant_paragraphs
