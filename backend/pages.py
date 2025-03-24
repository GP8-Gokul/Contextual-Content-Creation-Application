import fitz
import io
from sklearn.feature_extraction.text import TfidfVectorizer
import base64

def get_keyword_pages(pdf_bytes, refined_keyword_content, threshold=0.3, keyword_priority=True):
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    keyword_data = {keyword: fitz.open() for keyword in refined_keyword_content}

    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        page_text = page.get_text().lower()

        for keyword, content in refined_keyword_content.items():
            content_of_keyword = content.lower()

            # Exact keyword match check
            exact_match = keyword.lower() in page_text

            # Use TF-IDF for semantic relevance
            vectorizer = TfidfVectorizer(ngram_range=(1, 2), stop_words="english")
            tfidf_matrix = vectorizer.fit_transform([content_of_keyword, page_text])
            similarity_score = (tfidf_matrix[0] @ tfidf_matrix[1].T).toarray()[0, 0]

            # Apply higher threshold and prioritize exact match if enabled
            if exact_match or similarity_score > threshold:
                # Avoid adding duplicate pages
                if not page_in_doc(keyword_data[keyword], page_num):
                    keyword_data[keyword].insert_pdf(doc, from_page=page_num, to_page=page_num)

    # Save extracted pages to base64 for each keyword
    for keyword in keyword_data:
        if keyword_data[keyword].page_count > 0:
            pdf_bytes_io = io.BytesIO()
            keyword_data[keyword].save(pdf_bytes_io)
            keyword_data[keyword].close()
            keyword_data[keyword] = base64.b64encode(pdf_bytes_io.getvalue()).decode("utf-8")
        else:
            keyword_data[keyword] = None  # No relevant pages found

    return keyword_data