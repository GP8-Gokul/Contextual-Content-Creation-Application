import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

from transformers import pipeline

def initialize_classifier():
    global classifier 
    classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")

def keyword_content_mapping(refined_text, keywords):
    keyword_content = {}

    predictions = classifier(refined_text, candidate_labels=keywords, multi_label=True)


    for label, score in zip(predictions["labels"], predictions["scores"]):
        print(label, score)
        if score > 0.3:
            related_text = ". ".join([sentence for sentence in refined_text.split(". ") if label.lower() in sentence.lower()])
            keyword_content[label] = related_text if related_text else "No related text found."

    return keyword_content
    
def main():
    initialize_classifier()
    refined_text = "Machine learning and neural networks are transforming industries."
    keywords = ["AI"]
    print(keyword_content_mapping(refined_text, keywords))

if __name__ == "__main__":
    main()