import os
from flask import Flask

app = Flask(__name__)

db_user = os.environ.get('DB_USER', 'Inconnu')
db_pass = os.environ.get('DB_PASS', 'Inconnu')

@app.route('/')
def home():
    return f"<h1>Master GGT - API Web !</h1><p>Tentative de connexion en tant que : {db_user}</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
