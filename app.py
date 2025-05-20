from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

# Remova o bloco abaixo (não é necessário com Gunicorn)
# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)