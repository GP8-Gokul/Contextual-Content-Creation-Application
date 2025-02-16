from flask import Flask, request, jsonify
from flask_cors import CORS
import threading

from backend.get_studyplan import get_studyplan
from backend.process_content import process_content



def process_content_background(pdf_bytes, keywords):
    process_content(pdf_bytes, keywords)

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

    thread = threading.Thread(target=process_content_background, args=(pdf_bytes, keywords))
    thread.start()

    return jsonify({"message": "processing"})

@app.route('/studyplan', methods=['POST'])
def studyplan():
    data = request.get_json()
    user_id = data['user_id']

    response = get_studyplan(user_id)
    return jsonify(response)
    
if __name__ == '__main__':
    app.run(debug=True)