#!/usr/bin/env python3
# Importações padrão do Python
import random
import time
import threading
import datetime
import os
import logging
import json
import uuid
from typing import Dict, List, Optional

# Bibliotecas para métricas e API REST
from flask import Flask, jsonify, request, Response
from prometheus_client import (
    Counter, Gauge, Histogram, Summary, 
    generate_latest, REGISTRY
)

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('ml-metrics-exporter')

# Inicialização da aplicação Flask
app = Flask(__name__)

#################################################################
# DEFINIÇÃO DAS MÉTRICAS
#################################################################

# Grupo 1: Métricas de Transações e Predições (REQ-MON-*)
prediction_counter = Counter(
    'ml_predictions_total', 
    'Total de previsões realizadas, segmentadas por resultado e canal',
    ['result', 'channel']
)

fraud_counter = Counter(
    'ml_fraud_detected_total', 
    'Total de fraudes detectadas, segmentadas por tipo de fraude',
    ['fraud_type']
)

inference_errors = Counter(
    'inference_errors_total', 
    'Total de erros durante inferência, segmentados por tipo de erro',
    ['error_type']
)

# Grupo 2: Métricas de Qualidade do Modelo (REQ-ANO-*)
model_precision = Gauge(
    'model_precision', 
    'Precision do modelo de detecção de fraude',
    ['model_version', 'model_type']
)

model_recall = Gauge(
    'model_recall', 
    'Recall do modelo de detecção de fraude',
    ['model_version', 'model_type']
)

model_f1_score = Gauge(
    'model_f1_score', 
    'F1-Score do modelo de detecção de fraude',
    ['model_version', 'model_type']
)

model_drift_score = Gauge(
    'model_drift_score', 
    'Score de drift do modelo ao longo do tempo',
    ['feature_set', 'model_version']
)

prediction_fraud_rate = Gauge(
    'prediction_fraud_rate', 
    'Taxa de transações classificadas como fraude',
    ['channel', 'transaction_type']
)

model_version_gauge = Gauge(
    'model_version', 
    'Versão atual do modelo em produção',
    ['model_name', 'model_type']
)

# Grupo 3: Métricas de Performance e Disponibilidade (REQ-SEG-*)
uptime = Gauge(
    'uptime', 
    'Tempo de atividade do sistema em segundos'
)

service_health = Gauge(
    'service_health', 
    'Status de saúde do serviço (1=saudável, 0=degradado)',
    ['component']
)

# Grupo 4: Métricas de Latência (REQ-MON-004)
inference_latency = Histogram(
    'inference_latency_seconds', 
    'Latência de inferência do modelo em segundos',
    ['model_name', 'model_version'],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
)

fraud_detection_trigger_latency = Histogram(
    'fraud_detection_trigger_latency_seconds', 
    'Tempo de resposta para transações com suspeita de fraude',
    ['fraud_type', 'action_taken'],
    buckets=[0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0]
)

http_request_duration = Histogram(
    'http_request_duration_seconds', 
    'Duração das requisições HTTP',
    ['endpoint', 'method', 'status'],
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
)

prediction_latency = Summary(
    'prediction_latency_seconds', 
    'Latência das previsões do modelo',
    ['model_name', 'prediction_type']
)

# Grupo 5: Métricas de Compliance e Auditoria (REQ-SEG-003, REQ-EXP-*)
request_audit_counter = Counter(
    'request_audit_total', 
    'Contador de requisições para fins de auditoria',
    ['endpoint', 'user_id', 'request_type']
)

decision_audit_counter = Counter(
    'decision_audit_total', 
    'Contador de decisões do modelo para auditoria',
    ['decision_type', 'model_version', 'explainable']
)

dict_integration_status = Gauge(
    'dict_integration_status', 
    'Status da integração com o DICT (1=operacional, 0=falha)',
    ['operation_type']
)

blocked_accounts_total = Gauge(
    'blocked_accounts_total', 
    'Número total de contas bloqueadas por suspeita de fraude',
    ['block_reason', 'block_duration']
)

dict_query_latency = Histogram(
    'dict_query_latency_seconds', 
    'Latência das consultas ao DICT',
    ['operation_type'],
    buckets=[0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
)

dict_cache_hit_ratio = Gauge(
    'dict_cache_hit_ratio', 
    'Taxa de acerto do cache para consultas ao DICT'
)

# Grupo 6: Métricas de Segurança (REQ-SEG-*)
security_events_total = Counter(
    'security_events_total', 
    'Total de eventos de segurança detectados',
    ['severity', 'event_type']
)

data_validation_errors = Counter(
    'data_validation_errors_total', 
    'Total de erros de validação de dados de entrada',
    ['error_type', 'source']
)

# Inicialização de valores simulados para algumas métricas
# Valores para demonstração que seriam atualizados por sistemas reais
def initialize_metrics():
    model_precision.labels(model_version="1.0", model_type="xgboost").set(0.94)
    model_recall.labels(model_version="1.0", model_type="xgboost").set(0.91)
    model_f1_score.labels(model_version="1.0", model_type="xgboost").set(0.925)
    model_drift_score.labels(feature_set="base", model_version="1.0").set(0.03)
    prediction_fraud_rate.labels(channel="PIX", transaction_type="p2p").set(0.007)
    model_version_gauge.labels(model_name="fraude_pix_principal", model_type="xgboost").set(1)
    dict_integration_status.labels(operation_type="query").set(1)
    dict_integration_status.labels(operation_type="update").set(1)
    dict_cache_hit_ratio.set(0.85)
    service_health.labels(component="ml_serving").set(1)
    service_health.labels(component="dict_connector").set(1)
    service_health.labels(component="api_gateway").set(1)
    blocked_accounts_total.labels(block_reason="fraude_confirmada", block_duration="72h").set(10)
    blocked_accounts_total.labels(block_reason="suspeita_alta", block_duration="30d").set(5)
    blocked_accounts_total.labels(block_reason="multiplas_denuncias", block_duration="indefinido").set(3)

# Variáveis para simulação
start_time = time.time()
fraud_types = ["MULA_FINANCEIRA", "ENGENHARIA_SOCIAL", "INVASAO_CONTA", "GOLPE_FALSO_FUNCIONARIO", "PHISHING"]
channels = ["PIX", "TED", "BOLETO", "APP_MOBILE", "INTERNET_BANKING"]
transaction_types = ["p2p", "ecommerce", "bill_payment", "withdrawal", "deposit"]
error_types = ["timeout", "model_error", "feature_missing", "validation_error", "authentication_error"]
block_durations = ["72h", "30d", "indefinido"]
block_reasons = ["fraude_confirmada", "suspeita_alta", "multiplas_denuncias", "ordem_judicial", "atividade_atipica"]

#################################################################
# THREAD DE ATUALIZAÇÃO DE MÉTRICAS SIMULADAS
#################################################################

def update_metrics():
    """Thread que atualiza métricas simuladas periodicamente"""
    logger.info("Iniciando thread de atualização de métricas...")
    while True:
        try:
            # Atualizar uptime
            uptime.set(time.time() - start_time)
            
            # Simular predições e fraudes
            for _ in range(random.randint(5, 15)):
                channel = random.choice(channels)
                if random.random() < 0.1:  # 10% das transações são classificadas como fraude
                    prediction_counter.labels(result="fraud", channel=channel).inc()
                    if random.random() < 0.7:  # 70% das fraudes classificadas são reais
                        fraud_type = random.choice(fraud_types)
                        fraud_counter.labels(fraud_type=fraud_type).inc()
                else:
                    prediction_counter.labels(result="legitimate", channel=channel).inc()
            
            # Simular erros ocasionais de inferência
            if random.random() < 0.05:  # 5% de chance de erro
                error_type = random.choice(error_types)
                inference_errors.labels(error_type=error_type).inc()
            
            # Atualizar métricas de qualidade do modelo com pequenas variações
            # Obter valores atuais de forma segura
            try:
                curr_precision = float(model_precision.labels(model_version="1.0", model_type="xgboost")._value)
            except:
                curr_precision = 0.94
                
            try:
                curr_recall = float(model_recall.labels(model_version="1.0", model_type="xgboost")._value)
            except:
                curr_recall = 0.91
                
            try:
                curr_drift = float(model_drift_score.labels(feature_set="base", model_version="1.0")._value)
            except:
                curr_drift = 0.03
                
            try:
                curr_fraud_rate = float(prediction_fraud_rate.labels(channel="PIX", transaction_type="p2p")._value)
            except:
                curr_fraud_rate = 0.007
            
            # Adicionar pequenas variações aleatórias
            model_precision.labels(model_version="1.0", model_type="xgboost").set(
                max(0.7, min(0.99, curr_precision + random.uniform(-0.01, 0.01)))
            )
            model_recall.labels(model_version="1.0", model_type="xgboost").set(
                max(0.7, min(0.99, curr_recall + random.uniform(-0.01, 0.01)))
            )
            
            # Atualizar F1 com base em precision e recall
            try:
                new_precision = float(model_precision.labels(model_version="1.0", model_type="xgboost")._value)
                new_recall = float(model_recall.labels(model_version="1.0", model_type="xgboost")._value)
                if new_precision + new_recall > 0:  # Evitar divisão por zero
                    f1 = 2 * (new_precision * new_recall) / (new_precision + new_recall)
                    model_f1_score.labels(model_version="1.0", model_type="xgboost").set(f1)
            except:
                # Se não conseguir calcular, apenas atualiza com uma pequena variação
                model_f1_score.labels(model_version="1.0", model_type="xgboost").set(
                    max(0.7, min(0.99, 0.925 + random.uniform(-0.01, 0.01)))
                )
            
            model_drift_score.labels(feature_set="base", model_version="1.0").set(
                max(0.01, min(0.2, curr_drift + random.uniform(-0.005, 0.01)))
            )
            prediction_fraud_rate.labels(channel="PIX", transaction_type="p2p").set(
                max(0.001, min(0.05, curr_fraud_rate + random.uniform(-0.001, 0.002)))
            )
            
            # Simular contagem de contas bloqueadas
            for reason in block_reasons:
                for duration in block_durations:
                    # Usa .set() diretamente com um valor calculado
                    # em vez de tentar acessar o valor atual
                    curr_val = random.randint(1, 20)  # Simplificado
                    blocked_accounts_total.labels(
                        block_reason=reason, 
                        block_duration=duration
                    ).set(max(0, curr_val + random.randint(-2, 5)))
            
            # Simular eventos de segurança
            if random.random() < 0.2:  # 20% de chance de evento de segurança
                severity = random.choice(["low", "medium", "high", "critical"])
                event_type = random.choice([
                    "suspicious_login", "brute_force", "data_leak", 
                    "unauthorized_access", "unusual_pattern"
                ])
                security_events_total.labels(severity=severity, event_type=event_type).inc()
            
            # Simular erros de validação de dados
            if random.random() < 0.15:  # 15% de chance de erro de validação
                error_type = random.choice([
                    "missing_field", "invalid_format", "out_of_range", 
                    "type_mismatch", "constraint_violation"
                ])
                source = random.choice([
                    "mobile_app", "internet_banking", "partner_api", 
                    "batch_import", "third_party"
                ])
                data_validation_errors.labels(error_type=error_type, source=source).inc()
            
            # Simular latências
            inference_latency.labels(
                model_name="fraude_pix_principal", 
                model_version="1.0"
            ).observe(random.uniform(0.05, 0.3))
            
            fraud_detection_trigger_latency.labels(
                fraud_type=random.choice(fraud_types),
                action_taken=random.choice(["block", "alert", "additional_auth", "monitor"])
            ).observe(random.uniform(0.2, 1.0))
            
            prediction_latency.labels(
                model_name="fraude_pix_principal", 
                prediction_type="real_time"
            ).observe(random.uniform(0.05, 0.2))
            
            dict_query_latency.labels(
                operation_type="query"
            ).observe(random.uniform(0.1, 0.5))
            
            # Atualizar status de integração DICT ocasionalmente
            if random.random() < 0.05:  # 5% de chance de problema de integração
                dict_integration_status.labels(operation_type="query").set(0)  # Falha
                time.sleep(2)  # Simular falha por 2 segundos
                dict_integration_status.labels(operation_type="query").set(1)  # Restaurado
            
            # Atualizar cache hit ratio com pequenas variações
            try:
                current_hit_ratio = float(dict_cache_hit_ratio._value)
            except:
                current_hit_ratio = 0.85
                
            dict_cache_hit_ratio.set(max(0.7, min(0.95, current_hit_ratio + random.uniform(-0.02, 0.02))))
            
            # Pausa entre atualizações
            time.sleep(5)
        except Exception as e:
            logger.error(f"Erro na thread de atualização de métricas: {e}")
            time.sleep(5)  # Continua tentando em caso de erro

#################################################################
# ROTAS DA API
#################################################################

@app.route('/')
def home():
    """Página inicial da aplicação"""
    # Simular latência HTTP e registrar para métricas
    start_time_req = time.time()
    
    # Simulação de processamento de requisição
    processing_time = random.uniform(0.01, 0.05)
    time.sleep(processing_time)
    
    # Registrar métrica de auditoria
    request_audit_counter.labels(
        endpoint="/", 
        user_id=request.headers.get('X-User-ID', 'anonymous'),
        request_type="info"
    ).inc()
    
    # Registrar duração da requisição
    duration = time.time() - start_time_req
    http_request_duration.labels(
        endpoint="/",
        method=request.method,
        status=200
    ).observe(duration)
    
    return """
    <html>
        <head><title>MLSecOps - Monitoramento de Fraudes Pix</title></head>
        <body>
            <h1>Modelo preditivo MLSecOps para detecção de fraudes Pix</h1>
            <p>Sistema de monitoramento em execução</p>
            <p>Versão: 1.0.0</p>
            <p><a href="/metrics">Métricas Prometheus</a></p>
            <p><a href="/health">Status de Saúde</a></p>
        </body>
    </html>
    """

@app.route('/metrics')
def metrics():
    """Endpoint para exposição de métricas para o Prometheus"""
    return Response(generate_latest(REGISTRY), mimetype="text/plain")

@app.route('/health')
def health():
    """Endpoint de verificação de saúde do serviço"""
    # Registrar latência e auditoria
    start_time_req = time.time()
    
    request_audit_counter.labels(
        endpoint="/health", 
        user_id=request.headers.get('X-User-ID', 'system'),
        request_type="health_check"
    ).inc()
    
    # Preparar resposta
    health_data = {
        "status": "healthy",
        "version": "1.0.0",
        "uptime_seconds": time.time() - start_time,
        "components": {
            "ml_serving": True,  # Valor estático para evitar acesso direto ao estado interno
            "dict_connector": True,
            "api_gateway": True
        },
        "timestamp": datetime.datetime.now().isoformat()
    }
    
    # Registrar duração da requisição
    duration = time.time() - start_time_req
    http_request_duration.labels(
        endpoint="/health",
        method=request.method,
        status=200
    ).observe(duration)
    
    return jsonify(health_data)

@app.route('/simulate/prediction', methods=['POST'])
def simulate_prediction():
    """Endpoint para simular uma predição de fraude"""
    start_time_req = time.time()
    
    # Obter dados da requisição ou usar valores padrão
    data = request.json if request.is_json else {}
    transaction_id = data.get('transaction_id', str(uuid.uuid4()))
    amount = data.get('amount', random.uniform(10, 5000))
    channel = data.get('channel', random.choice(channels))
    transaction_type = data.get('transaction_type', random.choice(transaction_types))
    
    # Simular processamento de predição
    prediction_time = random.uniform(0.05, 0.2)
    time.sleep(prediction_time)
    
    # Decidir resultado da predição
    is_fraud = random.random() < 0.1  # 10% de chance de fraude
    fraud_type = random.choice(fraud_types) if is_fraud else None
    fraud_score = random.uniform(0.8, 0.99) if is_fraud else random.uniform(0.01, 0.3)
    
    # Registrar métricas
    if is_fraud:
        prediction_counter.labels(result="fraud", channel=channel).inc()
        if random.random() < 0.7:  # 70% são fraudes confirmadas
            fraud_counter.labels(fraud_type=fraud_type).inc()
            
            # Simular ação de bloqueio (sem tentar acessar o valor atual)
            block_duration = random.choice(block_durations)
            block_reason = random.choice(block_reasons)
            
            # Incrementar com um valor randômico pequeno
            blocked_accounts_total.labels(
                block_reason=block_reason, 
                block_duration=block_duration
            ).inc(1)  # Incrementa em 1 unidade
    else:
        prediction_counter.labels(result="legitimate", channel=channel).inc()
    
    # Registrar latência de predição
    prediction_latency.labels(
        model_name="fraude_pix_principal", 
        prediction_type="api_request"
    ).observe(prediction_time)
    
    # Registrar decisão para auditoria
    decision_audit_counter.labels(
        decision_type="fraud_prediction" if is_fraud else "legitimate_transaction",
        model_version="1.0",
        explainable="true"
    ).inc()
    
    # Preparar resposta com explicabilidade
    response_data = {
        "transaction_id": transaction_id,
        "is_fraud": is_fraud,
        "fraud_score": fraud_score,
        "fraud_type": fraud_type if is_fraud else None,
        "explainability": {
            "top_factors": [
                {"feature": "transaction_amount", "importance": 0.3, "value": amount},
                {"feature": "user_history", "importance": 0.25, "value": "limited"},
                {"feature": "transaction_time", "importance": 0.2, "value": "off_hours"},
                {"feature": "device_risk", "importance": 0.15, "value": "medium"},
                {"feature": "location", "importance": 0.1, "value": "unusual"}
            ] if is_fraud else [
                {"feature": "user_history", "importance": 0.35, "value": "good"},
                {"feature": "transaction_pattern", "importance": 0.3, "value": "normal"},
                {"feature": "device_recognition", "importance": 0.2, "value": "known"},
                {"feature": "amount", "importance": 0.1, "value": amount},
                {"feature": "time_of_day", "importance": 0.05, "value": "usual"}
            ]
        },
        "processing_time_ms": round(prediction_time * 1000, 2),
        "timestamp": datetime.datetime.now().isoformat()
    }
    
    # Registrar duração total da requisição HTTP
    duration = time.time() - start_time_req
    http_request_duration.labels(
        endpoint="/simulate/prediction",
        method=request.method,
        status=200
    ).observe(duration)
    
    return jsonify(response_data)

@app.route('/simulate/dict', methods=['POST'])
def simulate_dict_query():
    """Endpoint para simular consulta ao DICT"""
    start_time_req = time.time()
    
    # Obter dados da requisição ou usar valores padrão
    data = request.json if request.is_json else {}
    pix_key = data.get('pix_key', f"+55{random.randint(10000000000, 99999999999)}")
    operation = data.get('operation', 'query')
    
    # Simular latência na consulta ao DICT
    dict_latency = random.uniform(0.1, 0.5)
    time.sleep(dict_latency)
    
    # Registrar métrica de latência de consulta DICT
    dict_query_latency.labels(operation_type=operation).observe(dict_latency)
    
    # Simular ocasionalmente uma falha
    dict_error = random.random() < 0.05  # 5% de chance de erro
    
    if dict_error:
        error_response = {
            "status": "error",
            "error_code": "DICT_TIMEOUT",
            "error_message": "Timeout ao consultar o DICT",
            "timestamp": datetime.datetime.now().isoformat()
        }
        status_code = 500
        dict_integration_status.labels(operation_type=operation).set(0)  # Marcar como falha
    else:
        # Simular resposta de sucesso com dados fictícios
        status_code = 200
        dict_integration_status.labels(operation_type=operation).set(1)  # Marcar como sucesso
        
        # 10% de chance de ser uma chave suspeita
        is_suspicious = random.random() < 0.1
        
        error_response = {
            "status": "success",
            "pix_key": pix_key,
            "key_type": random.choice(["CPF", "CNPJ", "EMAIL", "PHONE"]),
            "owner_name": "Nome Fictício",
            "bank_code": str(random.randint(1, 999)).zfill(3),
            "account_type": random.choice(["CHECKING", "SAVINGS"]),
            "suspicious_flag": is_suspicious,
            "block_status": "BLOCKED" if is_suspicious and random.random() < 0.7 else "ACTIVE",
            "last_updated": datetime.datetime.now().isoformat(),
            "cache_hit": random.random() < 0.85  # 85% de chance de acerto no cache
        }
        
        # Atualizar taxa de acerto do cache
        if error_response["cache_hit"]:
            # Sempre usa set() diretamente com um valor fixo ou calculado
            dict_cache_hit_ratio.set(0.85)  # Valor fixo para simplificar
        else:
            dict_cache_hit_ratio.set(0.75)  # Valor fixo para simplificar
    
    # Registrar auditoria da requisição
    request_audit_counter.labels(
        endpoint="/simulate/dict", 
        user_id=request.headers.get('X-User-ID', 'system'),
        request_type=f"dict_{operation}"
    ).inc()
    
    # Registrar duração total da requisição HTTP
    duration = time.time() - start_time_req
    http_request_duration.labels(
        endpoint="/simulate/dict",
        method=request.method,
        status=status_code
    ).observe(duration)
    
    return jsonify(error_response), status_code

@app.route('/debug/metrics', methods=['GET'])
def debug_metrics():
    """Endpoint para depuração de métricas (apenas para desenvolvimento)"""
    # Criar uma resposta simplificada com algumas informações para debugging
    return jsonify({
        "info": "Endpoint para debugging de métricas disponível",
        "uptime_seconds": time.time() - start_time,
        "timestamp": datetime.datetime.now().isoformat(),
        "available_metrics": [
            "ml_predictions_total", 
            "model_precision", 
            "model_recall",
            "inference_latency_seconds",
            "dict_integration_status",
            "service_health",
            # Listar algumas métricas-chave
        ]
    })

#################################################################
# INICIALIZAÇÃO DA APLICAÇÃO
#################################################################

if __name__ == '__main__':
    # Inicializar valores de métricas
    initialize_metrics()
    
    # Iniciar thread de atualização de métricas em segundo plano
    logger.info("Iniciando thread de atualização de métricas...")
    update_thread = threading.Thread(target=update_metrics, daemon=True)
    update_thread.start()
    
    # Iniciar servidor web
    port = int(os.environ.get('PORT', 8080))
    logger.info(f"Iniciando servidor na porta {port}...")
    app.run(host='0.0.0.0', port=port)
    