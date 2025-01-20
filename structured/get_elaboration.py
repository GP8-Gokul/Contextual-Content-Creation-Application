import wikipedia

import os
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'


import tensorflow as tf
tf.get_logger().setLevel('ERROR')

def get_elaboration(content):
    for key, value in content.items():
        try:
            summary = wikipedia.summary(key, sentences=2)
            content[key] = value + " " + summary
        except wikipedia.exceptions.DisambiguationError as e:
            try:
                summary = wikipedia.summary(e.options[0], sentences=2)
                content[key] = value + " " + summary
            except wikipedia.exceptions.PageError:
                content[key] = value
        except wikipedia.exceptions.PageError:
            content[key] = value 
    return content