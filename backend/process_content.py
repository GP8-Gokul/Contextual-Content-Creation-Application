import fitz

from backend.clean_and_sort import clean_and_sort
from backend.refined_text import refined_text_re

def process_content(pdf_bytes, keywords):
    cleaned_text = clean_and_sort(pdf_bytes)
    refined_text = refined_text_re(cleaned_text)
    keyword_content = keyword_content_mapping(refined_text, keywords)

        
            
    

