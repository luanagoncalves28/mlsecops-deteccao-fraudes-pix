#!/bin/bash

# =======================================================================
# MLSecOps - Script de Testes de Resiliência
# Autor: Luana Gonçalves
# Data: 15/05/2025
# Descrição: Testa a resiliência do sistema simulando diferentes tipos de falhas
# =======================================================================

set -e
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sem cor

# Função para simular falha no serviço de inferência
test_inference_service_failure() {
    echo -e "${BLUE}Simulando falha no serviço de inferência...${NC}"
    
    # Escalar o deployment para 0 réplicas
    kubectl scale deployment ml-inference-service -n ml-serving --replicas=0
    
    echo -e "${YELLOW}Serviço de inferência interrompido. Verificando se alertas são gerados...${NC}"
    sleep 60  # Aguardar tempo suficiente para alertas serem gerados
    
    # Verificar se alertas foram gerados
    ALERTS=$(kubectl exec -n monitoring $(kubectl get pods -n monitoring -l app=prometheus -o jsonpath='{.items[0].metadata.name}') -- curl -s http://localhost:9090/api/v1/alerts)
    
    if echo "$ALERTS" | grep -q "ServiceUnavailable"; then
        echo -e "${GREEN}✓ Alerta gerado corretamente para serviço indis
# Continuação do código anterior
       echo -e "${GREEN}✓ Alerta gerado corretamente para serviço indisponível${NC}"
   else
       echo -e "${RED}✗ Alerta não gerado para serviço indisponível${NC}"
   fi
   
   # Restaurar o serviço
   kubectl scale deployment ml-inference-service -n ml-serving --replicas=1
   
   echo -e "${BLUE}Aguardando restauração do serviço...${NC}"
   kubectl rollout status deployment/ml-inference-service -n ml-serving --timeout=120s
   
   echo -e "${GREEN}Serviço de inferência restaurado${NC}"
}

# Função para simular alta latência
test_high_latency() {
   echo -e "${BLUE}Simulando alta latência no serviço de inferência...${NC}"
   
   # Injetar latência usando um configmap de configuração
   kubectl patch configmap ml-inference-config -n ml-serving --patch '{"data":{"DEBUG_LATENCY":"500"}}'
   
   echo -e "${YELLOW}Latência artificial injetada. Verificando se alertas são gerados...${NC}"
   sleep 60  # Aguardar tempo suficiente para alertas serem gerados
   
   # Verificar se alertas foram gerados
   ALERTS=$(kubectl exec -n monitoring $(kubectl get pods -n monitoring -l app=prometheus -o jsonpath='{.items[0].metadata.name}') -- curl -s http://localhost:9090/api/v1/alerts)
   
   if echo "$ALERTS" | grep -q "HighInferenceLatency"; then
       echo -e "${GREEN}✓ Alerta gerado corretamente para alta latência${NC}"
   else
       echo -e "${RED}✗ Alerta não gerado para alta latência${NC}"
   fi
   
   # Restaurar configuração normal
   kubectl patch configmap ml-inference-config -n ml-serving --patch '{"data":{"DEBUG_LATENCY":"0"}}'
   
   echo -e "${GREEN}Configuração normal restaurada${NC}"
}

# Função para simular drift nos dados
test_data_drift() {
   echo -e "${BLUE}Simulando drift nos dados de entrada...${NC}"
   
   # Criar um job que envia transações com drift para o sistema
   cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
 name: data-drift-simulation
 namespace: ml-serving
spec:
 template:
   spec:
     containers:
     - name: drift-simulator
       image: curlimages/curl:7.83.1
       command:
       - /bin/sh
       - -c
       - |
         # Enviar 100 transações com valores incomuns
         for i in {1..100}; do
           curl -X POST http://ml-metrics-exporter:8080/simulate/prediction \
             -H "Content-Type: application/json" \
             -d '{"amount": 99999, "user_id": "test-user", "transaction_type": "atypical", "time": "2025-05-16T03:00:00Z"}'
           sleep 0.1
         done
     restartPolicy: Never
 backoffLimit: 0
EOF
   
   echo -e "${YELLOW}Dados com drift injetados. Verificando se alertas são gerados...${NC}"
   sleep 60  # Aguardar tempo suficiente para alertas serem gerados
   
   # Verificar se alertas foram gerados
   ALERTS=$(kubectl exec -n monitoring $(kubectl get pods -n monitoring -l app=prometheus -o jsonpath='{.items[0].metadata.name}') -- curl -s http://localhost:9090/api/v1/alerts)
   
   if echo "$ALERTS" | grep -q "ModelDriftDetected"; then
       echo -e "${GREEN}✓ Alerta gerado corretamente para drift de dados${NC}"
   else
       echo -e "${RED}✗ Alerta não gerado para drift de dados${NC}"
   fi
   
   # Limpar o job
   kubectl delete job data-drift-simulation -n ml-serving
   
   echo -e "${GREEN}Teste de drift concluído${NC}"
}

# Função para simular um possível ataque adversarial
test_adversarial_attempt() {
   echo -e "${BLUE}Simulando tentativa de ataque adversarial...${NC}"
   
   # Criar um job que envia transações com padrões de ataque
   cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
 name: adversarial-simulation
 namespace: ml-serving
spec:
 template:
   spec:
     containers:
     - name: adversarial-simulator
       image: curlimages/curl:7.83.1
       command:
       - /bin/sh
       - -c
       - |
         # Enviar padrões suspeitos que podem confundir o modelo
         for i in {1..20}; do
           curl -X POST http://ml-metrics-exporter:8080/simulate/prediction \
             -H "Content-Type: application/json" \
             -d '{"amount": 9999999, "user_id": "test-attacker", "transaction_type": "p2p", "time": "2025-05-16T02:00:00Z", "device": "DeviceDesconhecido", "location": "Localização Atípica"}'
           sleep 0.5
         done
     restartPolicy: Never
 backoffLimit: 0
EOF
   
   echo -e "${YELLOW}Padrões adversariais injetados. Verificando se alertas são gerados...${NC}"
   sleep 60  # Aguardar tempo suficiente para alertas serem gerados
   
   # Verificar se alertas foram gerados
   ALERTS=$(kubectl exec -n monitoring $(kubectl get pods -n monitoring -l app=prometheus -o jsonpath='{.items[0].metadata.name}') -- curl -s http://localhost:9090/api/v1/alerts)
   
   if echo "$ALERTS" | grep -q "AdversarialAttackSuspected"; then
       echo -e "${GREEN}✓ Alerta gerado corretamente para tentativa de ataque adversarial${NC}"
   else
       echo -e "${RED}✗ Alerta não gerado para tentativa de ataque adversarial${NC}"
   fi
   
   # Limpar o job
   kubectl delete job adversarial-simulation -n ml-serving
   
   echo -e "${GREEN}Teste de ataque adversarial concluído${NC}"
}

# Menu principal
echo "==================================================="
echo "  MLSecOps - Testes de Resiliência"
echo "==================================================="
echo "Escolha o teste a ser executado:"
echo "1. Falha no serviço de inferência"
echo "2. Alta latência"
echo "3. Drift nos dados"
echo "4. Tentativa de ataque adversarial"
echo "5. Executar todos os testes"
echo "0. Sair"

read -p "Opção: " OPTION

case $OPTION in
   1)
       test_inference_service_failure
       ;;
   2)
       test_high_latency
       ;;
   3)
       test_data_drift
       ;;
   4)
       test_adversarial_attempt
       ;;
   5)
       test_inference_service_failure
       test_high_latency
       test_data_drift
       test_adversarial_attempt
       ;;
   0)
       echo "Saindo..."
       exit 0
       ;;
   *)
       echo "Opção inválida!"
       exit 1
       ;;
esac

echo -e "${GREEN}Testes de resiliência concluídos!${NC}"