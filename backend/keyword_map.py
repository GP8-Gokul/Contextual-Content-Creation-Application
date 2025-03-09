import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

from transformers import pipeline

def initialize_classifier():
    global classifier 
    classifier = pipeline("zero-shot-classification", model="MoritzLaurer/mDeBERTa-v3-base-mnli-xnli")

def keyword_content_mapping(chunks, keywords):
    keyword_content = {}

    for chunk in chunks:
        result = classifier(chunk, keywords, multi_label=True)
        for label, score in zip(result["labels"], result["scores"]):
            if score > 0.5:  
                keyword_content.setdefault(label, []).append(chunk)

    for key in keyword_content:
        keyword_content[key] = ' '.join(keyword_content[key])

    return keyword_content

    
def main():
    initialize_classifier()
    chunks = "Machine learning and neural networks are transforming industries."
    keywords = ["AI"]
    print(keyword_content_mapping(chunks, keywords))

if __name__ == "__main__":
    main()