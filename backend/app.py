from flask import Flask
import base64
from flask import request, jsonify

app = Flask(__name__)

@app.route('/process', methods=['POST'])
def home():
    data = request.get_json()
    pdf_base64 = data.get('pdf_base64')
    keywords = data.get('keywords')

    if not pdf_base64 or not keywords:
        return jsonify({"error": "Missing pdf_base64 or keywords"}), 400

    pdf_bytes = base64.b64decode(pdf_base64)

    
    return jsonify({"message": "PDF and keywords received successfully"})

if __name__ == '__main__':
    app.run(debug=True)