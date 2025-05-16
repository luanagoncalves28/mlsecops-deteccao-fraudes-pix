import time
from prometheus_client import Counter, Histogram, Gauge, push_to_gateway

# Configuração do endpoint Prometheus Push Gateway
PUSH_GATEWAY_URL = "prometheus-pushgateway:9091"
JOB_NAME = "ml_inference_service"

# Métricas básicas de inferência
inference_requests = Counter(
    'ml_inference_requests_total',
    'Total de requisições de inferência',
    ['model_name', 'model_version', 'result']
)

inference_latency = Histogram(
    'ml_inference_latency_seconds',
    'Latência das requisições de inferência',
    ['model_name', 'model_version'],
    buckets=[0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0]
)

# Métricas de segurança
adversarial_attempt_counter = Counter(
    'adversarial_attempts_total',
    'Contagem de tentativas detectadas de ataques adversariais',
    ['attack_type', 'detection_method', 'severity']
)

input_outlier_score = Histogram(
    'input_outlier_score',
    'Score de outlier para inputs',
    ['model_name'],
    buckets=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
)

# Função para detectar inputs potencialmente adversariais
def is_potential_adversarial(request_data):
    # Implementação simplificada:
    # Verifica valores extremos ou padrões suspeitos
    try:
        # Exemplo: valor de transação extremamente alto é suspeito
        if 'amount' in request_data and request_data['amount'] > 100000:
            return True
            
        # Exemplo: padrão suspeito de horário e valor
        if ('time' in request_data and 'amount' in request_data and 
            (0 <= request_data['time'].hour <= 4) and request_data['amount'] > 10000):
            return True
            
        return False
    except:
        return False

# Função para identificar o tipo de ataque
def detect_attack_type(request_data):
    # Lógica simplificada para identificar o tipo de ataque
    # Em produção, usaria técnicas mais sofisticadas
    if 'amount' in request_data and request_data['amount'] > 100000:
        return "amount_manipulation"
    return "unknown"

# Função para avaliar a severidade do ataque
def assess_severity(request_data):
    # Lógica simplificada para avaliar severidade
    if 'amount' in request_data and request_data['amount'] > 1000000:
        return "critical"
    return "medium"

# Middleware para métricas Prometheus
class MetricsMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, request):
        start_time = time.time()
        
        # Processar a request
        response = await self.app(request)
        
        # Extrair dados para métricas
        try:
            request_data = await request.json()
            model_name = request_data.get('model_name', 'unknown')
            model_version = request_data.get('model_version', 'unknown')
            
            # Verificar resultado da inferência 
            result = "unknown"
            if hasattr(response, 'body'):
                response_data = json.loads(response.body)
                result = "fraud" if response_data.get('is_fraud', False) else "legitimate"
            
            # Registrar métricas
            inference_requests.labels(
                model_name=model_name,
                model_version=model_version,
                result=result
            ).inc()
            
            inference_latency.labels(
                model_name=model_name,
                model_version=model_version
            ).observe(time.time() - start_time)
            
            # Verificar se é potencialmente um ataque adversarial
            if is_potential_adversarial(request_data):
                attack_type = detect_attack_type(request_data)
                severity = assess_severity(request_data)
                
                adversarial_attempt_counter.labels(
                    attack_type=attack_type,
                    detection_method="input_analysis",
                    severity=severity
                ).inc()
            
            # Enviar métricas para o Prometheus
            push_to_gateway(
                PUSH_GATEWAY_URL, 
                job=f"{JOB_NAME}_{model_name}",
                registry=REGISTRY
            )
                
        except Exception as e:
            # Registrar erro na coleta de métricas, mas não afetar a resposta
            print(f"Erro ao coletar métricas: {str(e)}")
        
        return response