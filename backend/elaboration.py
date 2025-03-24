import wikipedia
from sklearn.feature_extraction.text import TfidfVectorizer

def get_elaboration(refined_keyword_content):
    keyword_elaboration = {}

    for keyword, content in refined_keyword_content.items():
        search_results = wikipedia.search(keyword)

        if not search_results:
            continue  

        best_match = None
        best_match_score = 0

        for title in search_results:
            try:
                page = wikipedia.page(title)
                page_content = page.content.lower()

                content_with_keyword = f"{keyword} {content}".lower()

                vectorizer = TfidfVectorizer(ngram_range=(1, 2), stop_words='english')
                tfidf_matrix = vectorizer.fit_transform([content_with_keyword, page_content])
                
                match_score = (tfidf_matrix[0] @ tfidf_matrix[1].T).toarray()[0, 0]

                if match_score > best_match_score:
                    best_match_score = match_score
                    best_match = page

            except (wikipedia.exceptions.PageError, wikipedia.exceptions.DisambiguationError):
                continue 

        if best_match:
            keyword_elaboration[keyword] = best_match.summary

    return keyword_elaboration