from flask import Flask, request, jsonify
from flask_cors import CORS
import threading

from backend.get_studyplan import get_studyplan
from backend.process_content import process_content
from backend.keyword_map import initialize_classifier
from backend.refine_map import initialize_summarizer

def process_content_background(pdf_bytes, keywords,userid):
    process_content(pdf_bytes, keywords,userid)

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

    thread = threading.Thread(target=process_content_background, args=(pdf_bytes, keywords,userid))
    thread.start()

    return jsonify({"message": "processing"})

@app.route('/studyplan', methods=['POST'])
def studyplan():
    data = request.get_json()
    user_id = data['user_id']
    already_have = data['already_have']

    response = get_studyplan(user_id)
    return jsonify(response)
    
if __name__ == '__main__':
    initialize_classifier()
    initialize_summarizer()
    app.run(debug=True)