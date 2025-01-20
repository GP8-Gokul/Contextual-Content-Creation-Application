import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

from transformers import pipeline

def classify_text(text, classifier, candidate_labels):
    max_length = 512
    return classifier(text[:max_length], candidate_labels, multi_label=True)  

def keyword_content_mapping(sentences, keywords):
    keyword_content = {}
    classifier = pipeline("zero-shot-classification", model="MoritzLaurer/mDeBERTa-v3-base-mnli-xnli", device=0) 
    candidate_labels = keywords

    for sentence in sentences:
        result = classify_text(sentence, classifier, candidate_labels)
        labels = result['labels']
        scores = result['scores']

    for label, score in zip(labels, scores):
        if score > 0.4:
            keyword_content[label] = sentence
        
    return keyword_content
