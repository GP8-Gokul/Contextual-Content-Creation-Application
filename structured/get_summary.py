import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

from transformers import pipeline

def get_summary(content):
    for key, value in content.items():
        summarizer = pipeline('summarization', model="facebook/bart-large-cnn", tokenizer="facebook/bart-large-cnn", framework="tf", device=0)
        max_chunk_size = 512  
        chunks = [value[i:i+max_chunk_size] for i in range(0, len(value), max_chunk_size)]
        summary = ""
        for chunk in chunks:
            summary = summarizer(chunk, max_length=len(chunk), min_length=5, do_sample=False)
            summary += summary + " "
        content[key] = summary.strip()
    return content