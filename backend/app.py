from flask import Flask, request, jsonify
from flask_cors import CORS
import threading

from refine_map import initialize_summarizer
from firebase import addidtouser, addtofirebase
from process_content import process_content


import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

import warnings
warnings.filterwarnings("ignore", category=UserWarning)  


def process_content_background(pdf_bytes, keywords,userid,s_id):
    content = process_content(pdf_bytes, keywords,userid,s_id)
    addtofirebase(userid,s_id , content)

app = Flask(__name__)
CORS(app)

@app.route('/', methods=['GET'])
def home():
    return jsonify(message="Hello, World!")

@app.route('/add', methods=['POST'])
def add():
    data = request.get_json()
    pdf_bytes = data['pdf']
    keywords = data['keywords']
    userid = data['userid']

    s_id = addidtouser(userid)

    thread = threading.Thread(target=process_content_background, args=(pdf_bytes, keywords,userid,s_id))
    thread.start()

    return jsonify({"message": "processing", "s_id": s_id})
    
if __name__ == '__main__':
    initialize_summarizer()
    app.run(debug=True)