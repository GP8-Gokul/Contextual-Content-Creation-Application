from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def extract_relevant_paragraphs_with_neighbors(paragraphs, keyword, threshold=0.65, neighbor_threshold=0.5):
    selected_indices = set()

    for i, para in enumerate(paragraphs):
        if keyword.lower() in para.lower():
            selected_indices.add(i)
        
            if i > 0:
                selected_indices.add(i - 1)
            if i < len(paragraphs) - 1:
                selected_indices.add(i + 1)

    
    vectorizer = TfidfVectorizer(ngram_range=(1, 2), stop_words="english")
    tfidf_matrix = vectorizer.fit_transform(paragraphs + [keyword])
    
    
    keyword_vector = tfidf_matrix[-1]  
    similarities = cosine_similarity(keyword_vector, tfidf_matrix[:-1])[0]

    
    for i, score in enumerate(similarities):
        if score > threshold:  
            selected_indices.add(i)
            
            if i > 0 and similarities[i - 1] > neighbor_threshold:
                selected_indices.add(i - 1)
            if i < len(paragraphs) - 1 and similarities[i + 1] > neighbor_threshold:
                selected_indices.add(i + 1)

    
    relevant_paragraphs = []
    for i in sorted(selected_indices):
        para = paragraphs[i].strip()
        
        if len(para.split()) > 5 and len(set(para.lower().split())) > 3:  
            relevant_paragraphs.append(para)

    return relevant_paragraphs
