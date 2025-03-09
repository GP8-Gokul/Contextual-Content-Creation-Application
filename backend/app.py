from flask import Flask, request, jsonify
from flask_cors import CORS
import threading
import json

from firebase import addtofirebase
from get_studyplan import get_studyplan
from process_content import process_content
from keyword_map import initialize_classifier
from refine_map import initialize_summarizer

from connect import commit, get_cursor

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

    cursor=get_cursor()
    cursor.execute("INSERT INTO study_plan (user_id, content) VALUES (?, ?)", (userid, "wait"))
    s_id = cursor.lastrowid
    commit()

    thread = threading.Thread(target=process_content_background, args=(pdf_bytes, keywords,userid,s_id))
    thread.start()

    return jsonify({"message": "processing", "s_id": s_id})

@app.route('/studyplan', methods=['POST'])
def studyplan():
    data = request.get_json()
    user_id = data['user_id']
    s_id = data['s_id']

    data = get_studyplan(user_id,s_id)
    response = json.loads(data)
    return jsonify(response)
    
if __name__ == '__main__':
    initialize_classifier()
    initialize_summarizer()
    app.run(debug=True)