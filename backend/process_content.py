import fitz

from backend.chunks import convert_to_chunks
from backend.clean_and_sort import clean_and_sort
from backend.elaboration import get_elaboration
from backend.keyword_map import keyword_content_mapping
from backend.pages import get_keyword_pages
from backend.refine_map import refine_mapping
from backend.refined_text import refined_text_re

def process_content(pdf_bytes, keywords,userid):

    cleaned_text = clean_and_sort(pdf_bytes)
    refined_text = refined_text_re(cleaned_text)
    chunks = convert_to_chunks(refined_text)
    keyword_content = keyword_content_mapping(chunks, keywords)
    refined_keyword_content = refine_mapping(keyword_content)

    keyword_pages = get_keyword_pages(pdf_bytes, refined_keyword_content)
    keyword_elaboration = get_elaboration(refined_keyword_content)


    

        
            
    

