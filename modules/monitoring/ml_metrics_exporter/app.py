from flask import Flask
from prometheus_client import Counter, generate_latest

app = Flask(__name__)
prediction_counter = Counter('ml_predictions_total', 'Total de previsões realizadas')

@app.route('/')
def home():
    prediction_counter.inc()
    return "Modelo preditivo rodando..."

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)