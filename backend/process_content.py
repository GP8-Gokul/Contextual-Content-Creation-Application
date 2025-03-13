import base64
import fitz

from minerextraction import extraction
from chunks import convert_to_chunks
from clean_and_sort import clean_and_sort
from elaboration import get_elaboration
from insert_to_db import save_to_db
from keyword_map import keyword_content_mapping
from pages import get_keyword_pages
from refine_map import refine_mapping
from refined_text import refined_text_re
from check_keyword import extract_relevant_paragraphs_with_neighbors
import json
import sys

ROUTE = 1

def process_content(pdf_base64, keywords,userid,s_id):

    if ROUTE == 1:
        pdf_bytes = base64.b64decode(pdf_base64)
        paragraphs = extraction(pdf_bytes)
        print("extraction executed")
        keyword_content ={}
        for keyword in keywords:
            keyword_content [keyword]=extract_relevant_paragraphs_with_neighbors(paragraphs, keyword)
        with open("backend/keyword.json", 'w') as f:
            json.dump(keyword_content, f)
        print("keyword_content stored in keyword.json")
        sys.exit("Exiting the program after storing keyword_content in keyword.json")
    elif ROUTE == 2:
        cleaned_text = clean_and_sort(pdf_bytes)
        print("clean_and_sort executed")
        refined_text = refined_text_re(cleaned_text)
        print("refined_text_re executed")
        chunks = convert_to_chunks(refined_text)

    print("convert_to_chunks executed")
    
    #keyword_content = keyword_content_mapping(chunks, keywords)
    print("keyword_content_mapping executed")
    
    refined_keyword_content = keyword_content
    #refined_keyword_content = refine_mapping(keyword_content )
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
    
    #save_to_db(combined_dict, userid,s_id)
    #print("save_to_db executed")

    return combined_dict




    

        
            
    

