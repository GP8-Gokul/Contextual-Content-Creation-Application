import fitz
import io
from sklearn.feature_extraction.text import TfidfVectorizer
import base64

def get_keyword_pages(pdf_bytes, refined_keyword_content, threshold=0.3):
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    keyword_data = {keyword: [] for keyword in refined_keyword_content}

    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        page_text = page.get_text().lower()

        for keyword, content in refined_keyword_content.items():
            content_of_keyword = content.lower()

            if keyword.lower() in page_text:  # Direct match priority
                add_page_to_result(keyword_data, doc, page_num, keyword)
                continue

            vectorizer = TfidfVectorizer(ngram_range=(1, 2), stop_words="english")
            tfidf_matrix = vectorizer.fit_transform([content_of_keyword, page_text])
            similarity_score = (tfidf_matrix[0] @ tfidf_matrix[1].T).toarray()[0, 0]

            if similarity_score > threshold:
                add_page_to_result(keyword_data, doc, page_num, keyword)

    return keyword_data


def add_page_to_result(keyword_data, doc, page_num, keyword):
    """Insert page to the result if not already added."""
    page_text = doc.load_page(page_num).get_text()
    for existing_page in keyword_data[keyword]:
        decoded_pdf = fitz.open(stream=base64.b64decode(existing_page), filetype="pdf")
        if decoded_pdf.page_count > 0 and decoded_pdf[0].get_text() == page_text:
            return  

    new_pdf = fitz.open()
    new_pdf.insert_pdf(doc, from_page=page_num, to_page=page_num)
    pdf_bytes_io = io.BytesIO()
    new_pdf.save(pdf_bytes_io)
    new_pdf.close()
    keyword_data[keyword].append(base64.b64encode(pdf_bytes_io.getvalue()).decode("utf-8"))
