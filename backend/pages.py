import fitz
import io
from sklearn.feature_extraction.text import TfidfVectorizer

def get_keyword_pages(pdf_bytes, refined_keyword_content):
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    keyword_data = {keyword: [] for keyword in refined_keyword_content}  

    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        page_text = page.get_text()

        for keyword, content in refined_keyword_content.items():
        
            content_of_keyword = content.lower()

            vectorizer = TfidfVectorizer(ngram_range=(1, 2), stop_words="english")
            tfidf_matrix = vectorizer.fit_transform([content_of_keyword, page_text.lower()])
            similarity_score = (tfidf_matrix[0] @ tfidf_matrix[1].T).toarray()[0, 0]

            if similarity_score > 0.1:  # Set a relevance threshold
                new_pdf = fitz.open()
                new_pdf.insert_pdf(doc, from_page=page_num, to_page=page_num)

                pdf_bytes_io = io.BytesIO()
                new_pdf.save(pdf_bytes_io)
                new_pdf.close()

                keyword_data[keyword].append(pdf_bytes_io.getvalue())

    return keyword_data