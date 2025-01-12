from flask import Flask
import base64
from flask import request, jsonify

from extraction import extract_content

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def home():
    pdf_file = request.files.get('pdf_file')
    keywords = request.form.getlist('keywords')

    if not pdf_file or not keywords:
        return jsonify({"error": "Missing pdf_file or keywords"}), 400

    pdf_bytes = pdf_file.read()
    
    extract_content(pdf_bytes, keywords)

    response = jsonify({"message": "PDF and keywords received successfully"})
    

    return response

if __name__ == '__main__':
    app.run(debug=True)