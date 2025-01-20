import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

from nltk.tokenize import sent_tokenize

def extract_sentences(text):
    sentences = sent_tokenize(text)
    return sentences