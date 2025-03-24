import base64

from minerextraction import extraction
from elaboration import get_elaboration
from pages import get_keyword_pages
from refine_map import refine_mapping
from check_keyword import extract_relevant_paragraphs_with_neighbors

def process_content(pdf_base64, keywords,userid,s_id):

    pdf_bytes = base64.b64decode(pdf_base64)
    paragraphs = extraction(pdf_bytes)
    print("extraction executed")
    keyword_content ={}
    for keyword in keywords:
        keyword_content [keyword]=extract_relevant_paragraphs_with_neighbors(paragraphs, keyword)


    print("keyword_content_mapping executed")
    
    refined_keyword_content = refine_mapping(keyword_content )
    print("refine_mapping executed")

    
    keyword_pages = get_keyword_pages(pdf_bytes, refined_keyword_content)
    print("get_keyword_pages executed")
    
    keyword_elaboration = get_elaboration(refined_keyword_content)
    print("get_elaboration executed")
    
    combined_dict = {}
    for keyword in refined_keyword_content:
        combined_dict[keyword] = {
            'summary': refined_keyword_content[keyword],
            'pdfpages': keyword_pages.get(keyword, ""),
            'elaboration': keyword_elaboration.get(keyword, "")
        }
    print("combined_dict created")

    return combined_dict




    

        
            
    

