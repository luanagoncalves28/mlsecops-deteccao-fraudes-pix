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

# Novas métricas para alertas regulatórios
model_explainability_score = Gauge(
    'model_explainability_score',
    'Score de explicabilidade do modelo',
    ['model_version', 'model_type']
)

data_retention_compliance = Gauge(
    'data_retention_compliance',
    'Indicador de conformidade com retenção de dados (1=compliant, 0=non-compliant)'
)

audit_log_integrity = Gauge(
    'audit_log_integrity',
    'Integridade dos logs de auditoria (1=completa, 0=comprometida)'
)

# Métricas de Estabilidade Temporal
feature_stability_index = Gauge(
    'model_feature_stability_index', 
    'Índice de estabilidade populacional das features principais',
    ['feature_name', 'model_version']
)

temporal_reliability = Gauge(
    'model_temporal_reliability', 
    'Confiabilidade do modelo em diferentes períodos',
    ['time_period', 'model_version']
)

# Métricas de Imparcialidade e Viés
demographic_parity = Gauge(
    'model_demographic_parity',
    'Diferença de resultados entre grupos demográficos',
    ['demographic_group_a', 'demographic_group_b', 'model_version']
)

financial_fairness = Gauge(
    'financial_decision_fairness',
    'Equidade nas decisões financeiras entre diferentes perfis',
    ['profile_type', 'decision_type']
)

# Métricas de Incerteza
prediction_uncertainty = Histogram(
    'prediction_uncertainty_distribution',
    'Distribuição da incerteza nas predições do modelo',
    ['model_name', 'decision_threshold'],
    buckets=[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
)

# Métricas de Detecção de Ataques Adversariais
adversarial_attempt_counter = Counter(
    'adversarial_attempts_total',
    'Contagem de tentativas detectadas de ataques adversariais',
    ['attack_type', 'detection_method', 'severity']
)

# Métricas de Robustez do Modelo
model_robustness_score = Gauge(
    'model_robustness_score',
    'Score de robustez do modelo a variações nos dados de entrada',
    ['perturbation_type', 'model_version']
)

security_reliability_index = Gauge(
    'model_security_reliability_index',
    'Índice composto de confiabilidade de segurança do modelo',
    ['model_name', 'model_version']
)

# Métricas de Consistência das Explicações
explanation_consistency = Gauge(
    'xai_explanation_consistency',
    'Consistência das explicações geradas para decisões similares',
    ['explanation_method', 'decision_type']
)

feature_importance_alignment = Gauge(
    'feature_importance_business_alignment',
    'Alinhamento entre importância das features e regras de negócio definidas',
    ['feature_category', 'business_rule_set']
)

# Métricas de Ciclo de Vida do Modelo
model_freshness_days = Gauge(
    'model_freshness_days',
    'Dias desde o último treinamento/atualização do modelo',
    ['model_name', 'environment']
)

retraining_efficiency = Histogram(
    'model_retraining_efficiency',
    'Tempo e recursos necessários para retreinar o modelo',
    ['trigger_reason'],
    buckets=[60, 300, 900, 1800, 3600, 7200, 14400, 28800, 86400]  # segundos
)

automated_deployment_success = Gauge(
    'automated_deployment_success_rate',
    'Taxa de sucesso de deployments automatizados',
    ['deployment_stage', 'model_type']
)

# Métricas de Governança de Dados e Modelos
data_lineage_completeness = Gauge(
    'data_lineage_completeness',
    'Completude da rastreabilidade de dados até a origem',
    ['data_source', 'processing_stage']
)

governance_compliance = Gauge(
    'ml_governance_compliance',
    'Nível de conformidade com políticas de governança de ML',
    ['policy_category', 'compliance_framework']
)

documentation_quality = Gauge(
    'model_documentation_quality',
    'Avaliação da qualidade e completude da documentação do modelo',
    ['documentation_aspect']
)

# Métricas de Eficiência de Recursos
hardware_acceleration_efficiency = Gauge(
    'ml_hardware_acceleration_efficiency',
    'Eficiência de utilização de aceleradores (GPU/TPU)',
    ['accelerator_type', 'operation_type']
)

ml_carbon_footprint = Counter(
    'ml_carbon_footprint_grams',
    'Estimativa de emissão de carbono das operações de ML em gramas de CO2e',
    ['operation_type', 'energy_source']
)

# Métricas de Valor de Negócio
model_roi_gauge = Gauge(
    'model_financial_impact',
    'Impacto financeiro estimado do modelo em reais',
    ['impact_category', 'time_period']
)

human_effort_saved = Counter(
    'ml_human_effort_saved_minutes',
    'Tempo estimado economizado em tarefas manuais graças à automação',
    ['task_category', 'department']
)

# Métricas de Compliance Regulatório
bcb_compliance_score = Gauge(
    'bcb_403_compliance_score',
    'Nível de conformidade com a Resolução BCB n° 403',
    ['article_number', 'requirement_type']
)

regulatory_request_fulfillment_time = Histogram(
    'regulatory_request_fulfillment_seconds',
    'Tempo para atender pedidos regulatórios',
    ['request_type', 'requesting_entity'],
    buckets=[60, 300, 900, 3600, 14400, 86400, 259200, 604800]  # segundos a semanas
)

# Métricas de Confiança do Cliente
user_trust_score = Gauge(
    'user_trust_score',
    'Avaliação da confiança dos usuários no sistema',
    ['user_segment', 'interaction_type']
)

decision_contestation_rate = Gauge(
    'algorithmic_decision_contestation_rate',
    'Taxa de contestação de decisões tomadas pelo algoritmo',
    ['decision_type', 'user_segment']
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
    # Inicialização para as novas métricas
    model_explainability_score.labels(model_version="1.0", model_type="xgboost").set(0.95)
    data_retention_compliance.set(1)
    audit_log_integrity.set(1)
    
    # Inicialização das novas métricas MLSecOps
    feature_stability_index.labels(feature_name="transaction_amount", model_version="1.0").set(0.92)
    feature_stability_index.labels(feature_name="user_activity", model_version="1.0").set(0.89)
    feature_stability_index.labels(feature_name="device_fingerprint", model_version="1.0").set(0.95)
    
    temporal_reliability.labels(time_period="business_hours", model_version="1.0").set(0.95)
    temporal_reliability.labels(time_period="after_hours", model_version="1.0").set(0.88)
    temporal_reliability.labels(time_period="weekend", model_version="1.0").set(0.90)
    
    demographic_parity.labels(demographic_group_a="low_income", demographic_group_b="high_income", model_version="1.0").set(0.05)
    demographic_parity.labels(demographic_group_a="urban", demographic_group_b="rural", model_version="1.0").set(0.03)
    
    financial_fairness.labels(profile_type="individual", decision_type="transaction_block").set(0.97)
    financial_fairness.labels(profile_type="business", decision_type="transaction_block").set(0.96)
    
    model_robustness_score.labels(perturbation_type="noise", model_version="1.0").set(0.85)
    model_robustness_score.labels(perturbation_type="targeted", model_version="1.0").set(0.78)
    
    security_reliability_index.labels(model_name="fraude_pix_principal", model_version="1.0").set(0.92)
    
    explanation_consistency.labels(explanation_method="shap", decision_type="fraud_detection").set(0.88)
    explanation_consistency.labels(explanation_method="lime", decision_type="fraud_detection").set(0.85)
    
    feature_importance_alignment.labels(feature_category="temporal", business_rule_set="bcb403").set(0.90)
    feature_importance_alignment.labels(feature_category="behavioral", business_rule_set="bcb403").set(0.92)
    
    model_freshness_days.labels(model_name="fraud_detection", environment="production").set(3)
    
    automated_deployment_success.labels(deployment_stage="test", model_type="xgboost").set(0.98)
    automated_deployment_success.labels(deployment_stage="production", model_type="xgboost").set(0.95)
    
    data_lineage_completeness.labels(data_source="transactional", processing_stage="raw").set(0.98)
    data_lineage_completeness.labels(data_source="transactional", processing_stage="processed").set(0.95)
    
    governance_compliance.labels(policy_category="data_access", compliance_framework="bcb403").set(0.97)
    governance_compliance.labels(policy_category="model_governance", compliance_framework="bcb403").set(0.95)
    
    documentation_quality.labels(documentation_aspect="model_card").set(0.90)
    documentation_quality.labels(documentation_aspect="data_dictionary").set(0.92)
    
    hardware_acceleration_efficiency.labels(accelerator_type="gpu", operation_type="inference").set(0.75)
    hardware_acceleration_efficiency.labels(accelerator_type="cpu", operation_type="inference").set(0.85)
    
    model_roi_gauge.labels(impact_category="fraud_prevention", time_period="monthly").set(250000)
    model_roi_gauge.labels(impact_category="operational_efficiency", time_period="monthly").set(120000)
    
    bcb_compliance_score.labels(article_number="89", requirement_type="monitoramento_tempo_real").set(0.95)
    bcb_compliance_score.labels(article_number="91", requirement_type="deteccao_anomalias").set(0.92)
    
    user_trust_score.labels(user_segment="high_value", interaction_type="digital").set(0.88)
    user_trust_score.labels(user_segment="new_customer", interaction_type="digital").set(0.75)
    
    decision_contestation_rate.labels(decision_type="fraud_block", user_segment="retail").set(0.03)
    decision_contestation_rate.labels(decision_type="transaction_limit", user_segment="retail").set(0.07)

# Variáveis para simulação
start_time = time.time()
fraud_types = ["MULA_FINANCEIRA", "ENGENHARIA_SOCIAL", "INVASAO_CONTA", "GOLPE_FALSO_FUNCIONARIO", "PHISHING"]
channels = ["PIX", "TED", "BOLETO", "APP_MOBILE", "INTERNET_BANKING"]
transaction_types = ["p2p", "ecommerce", "bill_payment", "withdrawal", "deposit"]
error_types = ["timeout", "model_error", "feature_missing", "validation_error", "authentication_error"]
block_durations = ["72h", "30d", "indefinido"]
block_reasons = ["fraude_confirmada", "suspeita_alta", "multiplas_denuncias", "ordem_judicial", "atividade_atipica"]
attack_types = ["input_manipulation", "model_inversion", "membership_inference", "evasion_attack", "data_poisoning"]
detection_methods = ["input_analysis", "behavioral_patterns", "anomaly_detection", "model_specific_defense"]
severity_levels = ["low", "medium", "high", "critical"]
time_periods = ["business_hours", "after_hours", "weekend", "holiday"]
demographic_groups = ["low_income", "medium_income", "high_income", "urban", "rural", "young", "elderly"]
profile_types = ["individual", "business", "government", "non_profit"]
decision_types = ["transaction_block", "limit_increase", "authentication_challenge"]
perturbation_types = ["noise", "targeted", "boundary", "transfer"]
explanation_methods = ["shap", "lime", "counterfactual", "feature_importance"]
feature_categories = ["temporal", "behavioral", "transactional", "demographic", "device"]
business_rule_sets = ["bcb403", "internal_policy", "fraud_prevention", "aml"]
deployment_stages = ["dev", "test", "staging", "production"]
model_types = ["xgboost", "lightgbm", "neural_network", "ensemble"]
data_sources = ["transactional", "customer", "external", "derived"]
processing_stages = ["raw", "processed", "feature", "model_input"]
policy_categories = ["data_access", "model_governance", "security", "privacy", "operational"]
compliance_frameworks = ["bcb403", "iso27001", "gdpr", "pci_dss"]
documentation_aspects = ["model_card", "data_dictionary", "risk_assessment", "monitoring_plan"]
accelerator_types = ["cpu", "gpu", "tpu", "fpga"]
operation_types = ["training", "inference", "feature_extraction", "data_processing"]
impact_categories = ["fraud_prevention", "operational_efficiency", "customer_experience", "regulatory"]
time_periods_business = ["daily", "weekly", "monthly", "quarterly", "yearly"]
article_numbers = ["89", "91", "93", "95", "97"]
requirement_types = ["monitoramento_tempo_real", "deteccao_anomalias", "seguranca_dados", "auditoria"]
user_segments = ["retail", "high_value", "corporate", "new_customer", "long_term"]
interaction_types = ["digital", "branch", "phone", "third_party"]

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
            
            # Atualização para as novas métricas
            try:
                curr_explainability = float(model_explainability_score.labels(model_version="1.0", model_type="xgboost")._value)
            except:
                curr_explainability = 0.95
                
            model_explainability_score.labels(model_version="1.0", model_type="xgboost").set(
                max(0.7, min(0.99, curr_explainability + random.uniform(-0.01, 0.01)))
            )
            
            # Simulação ocasional de problemas de compliance
            if random.random() < 0.02:  # 2% de chance
                data_retention_compliance.set(0)
                time.sleep(3)  # Simular problema por 3 segundos
                data_retention_compliance.set(1)
            
            # Simulação ocasional de problemas no log de auditoria
            if random.random() < 0.01:  # 1% de chance
                audit_log_integrity.set(0)
                time.sleep(2)  # Simular problema por 2 segundos
                audit_log_integrity.set(1)
            
            # Simulação para as novas métricas MLSecOps
            # Estabilidade de features
            for feature_name in ["transaction_amount", "user_activity", "device_fingerprint"]:
                try:
                    curr_stability = float(feature_stability_index.labels(feature_name=feature_name, model_version="1.0")._value)
                except:
                    curr_stability = 0.9
                feature_stability_index.labels(feature_name=feature_name, model_version="1.0").set(
                    max(0.7, min(0.99, curr_stability + random.uniform(-0.01, 0.01)))
                )
            
            # Confiabilidade temporal
            for period in time_periods[:3]:  # Limitar a 3 períodos para simplificar
                try:
                    curr_reliability = float(temporal_reliability.labels(time_period=period, model_version="1.0")._value)
                except:
                    curr_reliability = 0.9
                temporal_reliability.labels(time_period=period, model_version="1.0").set(
                    max(0.7, min(0.99, curr_reliability + random.uniform(-0.01, 0.01)))
                )
            
            # Métricas de equidade e viés
            demo_pairs = [("low_income", "high_income"), ("urban", "rural")]
            for group_a, group_b in demo_pairs:
                try:
                    curr_parity = float(demographic_parity.labels(demographic_group_a=group_a, demographic_group_b=group_b, model_version="1.0")._value)
                except:
                    curr_parity = 0.05
                demographic_parity.labels(demographic_group_a=group_a, demographic_group_b=group_b, model_version="1.0").set(
                    max(0.01, min(0.15, curr_parity + random.uniform(-0.01, 0.01)))
                )
            
            # Equidade nas decisões financeiras
            for profile in profile_types[:2]:  # Limitar a 2 perfis
                for decision in decision_types[:2]:  # Limitar a 2 tipos de decisão
                    try:
                        curr_fairness = float(financial_fairness.labels(profile_type=profile, decision_type=decision)._value)
                    except:
                        curr_fairness = 0.95
                    financial_fairness.labels(profile_type=profile, decision_type=decision).set(
                        max(0.8, min(0.99, curr_fairness + random.uniform(-0.01, 0.01)))
                    )
            
            # Incerteza das predições
            prediction_uncertainty.labels(
                model_name="fraude_pix_principal",
                decision_threshold="0.5"
            ).observe(random.uniform(0.1, 0.4))
            
            # Simulação de tentativas adversariais
            if random.random() < 0.1:  # 10% de chance de detectar tentativa adversarial
                attack_type = random.choice(attack_types)
                detection_method = random.choice(detection_methods)
                severity = random.choice(severity_levels)
                adversarial_attempt_counter.labels(
                    attack_type=attack_type,
                    detection_method=detection_method,
                    severity=severity
                ).inc()
            
            # Atualização de robustez do modelo
            for perturbation in perturbation_types[:2]:
                try:
                    curr_robustness = float(model_robustness_score.labels(perturbation_type=perturbation, model_version="1.0")._value)
                except:
                    curr_robustness = 0.8
                model_robustness_score.labels(perturbation_type=perturbation, model_version="1.0").set(
                    max(0.6, min(0.95, curr_robustness + random.uniform(-0.02, 0.02)))
                )
            
            # Índice de confiabilidade de segurança
            try:
                curr_reliability = float(security_reliability_index.labels(model_name="fraude_pix_principal", model_version="1.0")._value)
            except:
                curr_reliability = 0.92
            security_reliability_index.labels(model_name="fraude_pix_principal", model_version="1.0").set(
                max(0.7, min(0.99, curr_reliability + random.uniform(-0.02, 0.02)))
            )
            
            # Consistência das explicações
            for method in explanation_methods[:2]:
                try:
                    curr_consistency = float(explanation_consistency.labels(explanation_method=method, decision_type="fraud_detection")._value)
                except:
                    curr_consistency = 0.85
                explanation_consistency.labels(explanation_method=method, decision_type="fraud_detection").set(
                    max(0.7, min(0.95, curr_consistency + random.uniform(-0.03, 0.03)))
                )
            
            # Alinhamento de importância de features
            for category in feature_categories[:2]:
                try:
                    curr_alignment = float(feature_importance_alignment.labels(feature_category=category, business_rule_set="bcb403")._value)
                except:
                    curr_alignment = 0.9
                feature_importance_alignment.labels(feature_category=category, business_rule_set="bcb403").set(
                    max(0.75, min(0.98, curr_alignment + random.uniform(-0.02, 0.02)))
                )
            
            # Idade do modelo
            try:
                curr_days = float(model_freshness_days.labels(model_name="fraud_detection", environment="production")._value)
            except:
                curr_days = 3
            model_freshness_days.labels(model_name="fraud_detection", environment="production").set(
                curr_days + (1/24)  # Aumenta aproximadamente 1 hora a cada 5 segundos para simulação
            )
            
            # Eficiência de retreinamento
            if random.random() < 0.05:  # 5% de chance de simular um retreinamento
                retraining_efficiency.labels(
                    trigger_reason=random.choice(["scheduled", "drift_detected", "performance_drop", "new_data"])
                ).observe(random.uniform(1800, 7200))  # Entre 30min e 2h
            
            # Taxa de sucesso de deployments
            for stage in deployment_stages:
                try:
                    curr_success = float(automated_deployment_success.labels(deployment_stage=stage, model_type="xgboost")._value)
                except:
                    curr_success = 0.95
                automated_deployment_success.labels(deployment_stage=stage, model_type="xgboost").set(
                    max(0.7, min(0.99, curr_success + random.uniform(-0.03, 0.03)))
                )
            
            # Completude de linhagem de dados
            for source in data_sources[:2]:
                for stage in processing_stages[:2]:
                    try:
                        curr_completeness = float(data_lineage_completeness.labels(data_source=source, processing_stage=stage)._value)
                    except:
                        curr_completeness = 0.95
                    data_lineage_completeness.labels(data_source=source, processing_stage=stage).set(
                        max(0.8, min(0.99, curr_completeness + random.uniform(-0.02, 0.02)))
                    )
            
            # Compliance de governança
            for policy in policy_categories[:2]:
                try:
                    curr_compliance = float(governance_compliance.labels(policy_category=policy, compliance_framework="bcb403")._value)
                except:
                    curr_compliance = 0.95
                governance_compliance.labels(policy_category=policy, compliance_framework="bcb403").set(
                    max(0.8, min(0.99, curr_compliance + random.uniform(-0.02, 0.02)))
                )
            
            # Qualidade da documentação
            for aspect in documentation_aspects[:2]:
                try:
                    curr_quality = float(documentation_quality.labels(documentation_aspect=aspect)._value)
                except:
                    curr_quality = 0.9
                documentation_quality.labels(documentation_aspect=aspect).set(
                    max(0.7, min(0.98, curr_quality + random.uniform(-0.02, 0.02)))
                )
            
            # Eficiência de hardware
            for accel_type in accelerator_types[:2]:
                for op_type in operation_types[:2]:
                    try:
                        curr_efficiency = float(hardware_acceleration_efficiency.labels(accelerator_type=accel_type, operation_type=op_type)._value)
                    except:
                        curr_efficiency = 0.8
                    hardware_acceleration_efficiency.labels(accelerator_type=accel_type, operation_type=op_type).set(
                        max(0.6, min(0.95, curr_efficiency + random.uniform(-0.03, 0.03)))
                    )
            
            # Pegada de carbono
            ml_carbon_footprint.labels(
                operation_type=random.choice(operation_types),
                energy_source=random.choice(["grid", "renewable", "mixed"])
            ).inc(random.uniform(10, 100))
            
            # ROI do modelo
            for impact in impact_categories[:2]:
                for period in time_periods_business[:2]:
                    try:
                        curr_roi = float(model_roi_gauge.labels(impact_category=impact, time_period=period)._value)
                    except:
                        curr_roi = 200000
                    model_roi_gauge.labels(impact_category=impact, time_period=period).set(
                        max(100000, min(500000, curr_roi + random.uniform(-10000, 15000)))
                    )
            
            # Economia de esforço humano
            human_effort_saved.labels(
                task_category=random.choice(["review", "investigation", "reporting", "monitoring"]),
                department=random.choice(["fraud", "compliance", "operations", "customer_service"])
            ).inc(random.uniform(5, 30))
            
            # Compliance com regulações BCB
            for article in article_numbers[:2]:
                for req_type in requirement_types[:2]:
                    try:
                        curr_score = float(bcb_compliance_score.labels(article_number=article, requirement_type=req_type)._value)
                    except:
                        curr_score = 0.93
                    bcb_compliance_score.labels(article_number=article, requirement_type=req_type).set(
                        max(0.8, min(0.99, curr_score + random.uniform(-0.02, 0.02)))
                    )
            
            # Tempo para atender requisições regulatórias
            regulatory_request_fulfillment_time.labels(
                request_type=random.choice(["audit", "data_access", "report", "explanation"]),
                requesting_entity=random.choice(["bcb", "internal", "external_audit", "customer"])
            ).observe(random.uniform(900, 14400))  # Entre 15min e 4h
            
            # Score de confiança do usuário
            for segment in user_segments[:2]:
                for interaction in interaction_types[:2]:
                    try:
                        curr_trust = float(user_trust_score.labels(user_segment=segment, interaction_type=interaction)._value)
                    except:
                        curr_trust = 0.85
                    user_trust_score.labels(user_segment=segment, interaction_type=interaction).set(
                        max(0.6, min(0.95, curr_trust + random.uniform(-0.03, 0.03)))
                    )
            
            # Taxa de contestação de decisões
            for decision in decision_types[:2]:
                try:
                    curr_rate = float(decision_contestation_rate.labels(decision_type=decision, user_segment="retail")._value)
                except:
                    curr_rate = 0.05
                decision_contestation_rate.labels(decision_type=decision, user_segment="retail").set(
                    max(0.01, min(0.2, curr_rate + random.uniform(-0.01, 0.01)))
                )
            
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

# Adicionar novos endpoints para métricas específicas de MLSecOps
@app.route('/simulate/adversarial', methods=['POST'])
def simulate_adversarial_attempt():
    """Endpoint para simular tentativas de ataques adversariais"""
    start_time_req = time.time()
    
    # Obter dados da requisição ou usar valores padrão
    data = request.json if request.is_json else {}
    attack_type = data.get('attack_type', random.choice(attack_types))
    severity = data.get('severity', random.choice(severity_levels))
    
    # Simular latência de processamento
    processing_time = random.uniform(0.05, 0.2)
    time.sleep(processing_time)
    
    # Registrar a tentativa adversarial
    adversarial_attempt_counter.labels(
        attack_type=attack_type,
        detection_method="endpoint_detection",
        severity=severity
    ).inc()
    
    # Preparar resposta
    response_data = {
        "status": "detected",
        "attack_type": attack_type,
        "severity": severity,
        "timestamp": datetime.datetime.now().isoformat(),
        "defensive_action": random.choice(["block", "log", "challenge", "throttle"])
    }
    
    # Registrar duração total da requisição HTTP
    duration = time.time() - start_time_req
    http_request_duration.labels(
        endpoint="/simulate/adversarial",
        method=request.method,
        status=200
    ).observe(duration)
    
    return jsonify(response_data)

@app.route('/simulate/compliance_check', methods=['POST'])
def simulate_compliance_check():
    """Endpoint para simular verificações de compliance"""
    start_time_req = time.time()
    
    # Obter dados da requisição ou usar valores padrão
    data = request.json if request.is_json else {}
    article_number = data.get('article_number', random.choice(article_numbers))
    requirement_type = data.get('requirement_type', random.choice(requirement_types))
    
    # Simular latência de processamento
    processing_time = random.uniform(0.5, 2.0)
    time.sleep(processing_time)
    
    # Simular resultado da verificação
    is_compliant = random.random() < 0.9  # 90% de chance de estar conforme
    compliance_score = random.uniform(0.85, 0.99) if is_compliant else random.uniform(0.6, 0.84)
    
    # Atualizar métricas
    bcb_compliance_score.labels(
        article_number=article_number,
        requirement_type=requirement_type
    ).set(compliance_score)
    
    # Preparar resposta
    response_data = {
        "status": "success",
        "article_number": article_number,
        "requirement_type": requirement_type,
        "is_compliant": is_compliant,
        "compliance_score": compliance_score,
        "issues": [] if is_compliant else [
            {"issue_type": "documentation", "severity": "medium", "description": "Documentação incompleta"},
            {"issue_type": "monitoring", "severity": "low", "description": "Frequência de monitoramento insuficiente"}
        ],
        "timestamp": datetime.datetime.now().isoformat()
    }
    
    # Registrar duração total da requisição HTTP
    duration = time.time() - start_time_req
    http_request_duration.labels(
        endpoint="/simulate/compliance_check",
        method=request.method,
        status=200
    ).observe(duration)
    
    return jsonify(response_data)

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