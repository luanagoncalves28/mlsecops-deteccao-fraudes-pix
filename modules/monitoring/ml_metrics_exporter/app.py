# Importações padrão do Python
import random
import time
import threading

# Tentar importar bibliotecas externas com tratamento de erro
try:
    from flask import Flask, jsonify
    from prometheus_client import Counter, Gauge, Histogram, Summary, generate_latest
except ImportError:
    print("Erro: Flask ou prometheus_client não estão instalados.")
    print("Instale com: pip install flask prometheus_client")
    # Em produção, usaríamos sys.exit(1) aqui, mas para desenvolvimento continuamos
    # Definindo classes fictícias para permitir que o código seja analisado
    class Flask:
        def __init__(self, name): self.name = name
        def route(self, path): return lambda x: x
    def jsonify(x): return x
    class Counter:
        def __init__(self, name, help): pass
        def inc(self, amount=1): pass
    class Gauge:
        def __init__(self, name, help): pass
        def set(self, value): self._value = value
    class Histogram:
        def __init__(self, name, help, buckets=None): pass
        def observe(self, value): pass
    class Summary:
        def __init__(self, name, help): pass
        def observe(self, value): pass
    def generate_latest(): return b""

app = Flask(__name__)

# Contadores básicos
prediction_counter = Counter('ml_predictions_total', 'Total de previsões realizadas')
fraud_counter = Counter('ml_fraud_detected_total', 'Total de fraudes detectadas')
inference_errors = Counter('inference_errors_total', 'Total de erros durante inferência')

# Gauges para métricas que podem subir e descer
model_precision = Gauge('model_precision', 'Precision do modelo de detecção de fraude')
model_recall = Gauge('model_recall', 'Recall do modelo de detecção de fraude')
model_drift_score = Gauge('model_drift_score', 'Score de drift do modelo ao longo do tempo')
prediction_fraud_rate = Gauge('prediction_fraud_rate', 'Taxa de transações classificadas como fraude')
model_version = Gauge('model_version', 'Versão atual do modelo em produção')
uptime = Gauge('uptime', 'Tempo de atividade do sistema em segundos')

# Histogramas e summaries para distribuições
inference_latency = Histogram('inference_latency_seconds', 'Latência de inferência do modelo em segundos',
                              buckets=[0.05, 0.1, 0.2, 0.5, 1.0, 2.0])
fraud_detection_trigger_latency = Histogram('fraud_detection_trigger_latency_seconds', 
                                          'Tempo de resposta para transações com suspeita de fraude',
                                          buckets=[0.1, 0.5, 1.0, 2.0, 5.0])
http_request_duration = Histogram('http_request_duration_seconds', 'Duração das requisições HTTP',
                                buckets=[0.05, 0.1, 0.5, 1.0, 5.0])
prediction_latency = Summary('prediction_latency_seconds', 'Latência das previsões do modelo')

# Inicialização de valores simulados
model_precision.set(0.94)
model_recall.set(0.91)
model_drift_score.set(0.03)
prediction_fraud_rate.set(0.007)
model_version.set(1)
start_time = time.time()

# Thread de atualização de métricas simuladas
def update_metrics():
    while True:
        # Simular inferências
        prediction_counter.inc(random.randint(5, 15))
        
        # Simular detecções de fraude
        if random.random() < 0.3:  # 30% de chance de detectar fraude
            fraud_counter.inc(random.randint(1, 3))
        
        # Simular erros ocasionais
        if random.random() < 0.05:  # 5% de chance de erro
            inference_errors.inc()
        
        # Atualizar métricas de qualidade do modelo com pequenas variações
        model_precision.set(max(0.7, min(0.99, model_precision._value + random.uniform(-0.01, 0.01))))
        model_recall.set(max(0.7, min(0.99, model_recall._value + random.uniform(-0.01, 0.01))))
        model_drift_score.set(max(0.01, min(0.2, model_drift_score._value + random.uniform(-0.005, 0.01))))
        prediction_fraud_rate.set(max(0.001, min(0.05, prediction_fraud_rate._value + random.uniform(-0.001, 0.002))))
        
        # Atualizar uptime
        uptime.set(time.time() - start_time)
        
        # Simular latências
        inference_latency.observe(random.uniform(0.05, 0.3))
        fraud_detection_trigger_latency.observe(random.uniform(0.2, 1.0))
        prediction_latency.observe(random.uniform(0.05, 0.2))
        
        # Pausa antes da próxima atualização
        time.sleep(5)

# Iniciar thread de atualização em segundo plano
update_thread = threading.Thread(target=update_metrics, daemon=True)
update_thread.start()

@app.route('/')
def home():
    # Simulação de latência HTTP
    start = time.time()
    prediction_counter.inc()
    
    # Simular algum processamento
    process_time = random.uniform(0.01, 0.1)
    time.sleep(process_time)
    
    # Registrar duração
    http_request_duration.observe(time.time() - start)
    
    return "Modelo preditivo MLSecOps para detecção de fraudes Pix em execução."

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': 'text/plain; charset=utf-8'}

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "version": "1.0.0"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)