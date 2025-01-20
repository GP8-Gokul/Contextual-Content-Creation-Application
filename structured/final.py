from clean_content import clean_content
from clean_text import clean_text
from extract_sentences import extract_sentences
from extract_text_from_pdf import extract_and_sort_text
from get_elaboration import get_elaboration
from get_summary import get_summary
from keyword_content_mapping import keyword_content_mapping

import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

def print_content(content):
    for key, value in content.items():
        print(f"Keyword: {key}")
        print(f"Content: {value}")
        print("\n")

def choices(cleaned_content):
    print("Enter 1 to get the content")
    print("Enter 2 to get summary")
    print("Enter 3 to get elaboration")
    choice = int(input("Enter your choice: "))
    if choice == 1:
        print_content(cleaned_content)
    elif choice == 2:
        summary = get_summary(cleaned_content)
        print_content(summary)
    elif choice == 3:
        elaboration = get_elaboration(cleaned_content)
        print_content(elaboration)
    else:
        print("Invalid choice. Please enter a valid choice.")
        choices()


def main():
    number_of_keywords = int(input("Enter the number of keywords: "))

    keywords = []

    for i in range(number_of_keywords):
        keyword = input(f"Enter keyword {i+1}: ")
        keywords.append(keyword)

    input_file_path = input("Enter the path of the input file: ")
    extracted_text = extract_and_sort_text(input_file_path)  #done
    sentences = clean_text(extracted_text)                #done
    #sentences = extract_sentences(cleaned_text)
    keyword_content = keyword_content_mapping(sentences, keywords)
    cleaned_content = clean_content(keyword_content)

    choices(cleaned_content)
    


if __name__ == "__main__":
    main()


