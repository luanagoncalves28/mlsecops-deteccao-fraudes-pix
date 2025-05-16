# Procedimentos de Recuperação para Alertas do Sistema MLSecOps

Este documento descreve os procedimentos de recuperação para diversos alertas que podem ser acionados pelo sistema de monitoramento do MLSecOps de Detecção de Fraudes Pix.

## Índice

- [Procedimentos de Recuperação para Alertas do Sistema MLSecOps](#procedimentos-de-recuperação-para-alertas-do-sistema-mlsecops)
  - [Índice](#índice)
  - [Alertas de Infraestrutura](#alertas-de-infraestrutura)
    - [ServiceUnavailable](#serviceunavailable)
    - [ClusterHighCPU](#clusterhighcpu)
  - [Alertas de ML](#alertas-de-ml)
    - [ModelDriftDetected](#modeldriftdetected)
    - [HighInferenceLatency](#highinferencelatency)
    - [ModelPerformanceDegradation](#modelperformancedegradation)
  - [Alertas de Segurança](#alertas-de-segurança)
    - [AdversarialAttackSuspected](#adversarialattacksuspected)
  - [Alertas de Compliance](#alertas-de-compliance)
    - [RegulatoryComplianceIssue](#regulatorycomplianceissue)

## Alertas de Infraestrutura

### ServiceUnavailable

**Descrição**: Um serviço crítico está indisponível.

**Ações de Recuperação**:

1. Verificar o status do deployment:
kubectl get deployments -n <namespace> <deployment-name>
2. Verificar os pods associados:
kubectl get pods -n <namespace> -l app=<app-label>
3. Verificar logs dos pods:
kubectl logs -n <namespace> <pod-name> --tail=100

4. Se necessário, reiniciar o deployment:
kubectl rollout restart deployment -n <namespace> <deployment-name>

5. Verificar se há problemas com a API de autenticação:
kubectl describe pods -n <namespace> <pod-name>

6. Escalar para equipe de infraestrutura se o problema persistir.

### ClusterHighCPU

**Descrição**: Uso elevado de CPU no cluster Kubernetes.

**Ações de Recuperação**:

1. Identificar pods consumindo mais recursos:
kubectl top pods --all-namespaces

2. Verificar se há jobs batch consumindo muitos recursos:
kubectl get jobs --all-namespaces

3. Considerar escalar horizontalmente o deployment afetado:
kubectl scale deployment -n <namespace> <deployment-name> --replicas=<novo-número>

4. Verificar a necessidade de solicitar aumento de recursos do cluster.

## Alertas de ML

### ModelDriftDetected

**Descrição**: Drift significativo detectado nos dados de entrada ou predições do modelo.

**Ações de Recuperação**:

1. Verificar o dashboard "ML Model Health" para identificar quais features estão apresentando drift.

2. Analisar a distribuição das features afetadas:
kubectl exec -n ml-serving <pod-ml-analysis> -- python /app/analyze_drift.py

3. Caso seja um drift legítimo (e não um possível ataque):
- Iniciar processo de retreinamento do modelo:
  ```
  kubectl create job -n ml-serving model-retraining --from=cronjob/model-retraining-schedule
  ```
- Monitorar o job de retreinamento:
  ```
  kubectl logs -n ml-serving job/model-retraining -f
  ```

4. Caso seja suspeita de tentativa de manipulação:
- Ativar regras mais rigorosas temporariamente:
  ```
  kubectl patch configmap ml-inference-config -n ml-serving --patch '{"data":{"SECURITY_LEVEL":"HIGH"}}'
  ```
- Notificar equipe de segurança.

### HighInferenceLatency

**Descrição**: Latência de inferência acima do limiar aceitável.

**Ações de Recuperação**:

1. Verificar recursos dos pods de inferência:
kubectl top pods -n ml-serving -l app=ml-inference

2. Verificar se há backlog de requisições:
kubectl exec -n ml-serving <pod-name> -- curl localhost:8080/metrics | grep queue_size

3. Escalar horizontalmente o serviço:
kubectl scale deployment -n ml-serving ml-inference --replicas=<current+2>

4. Verificar logs em busca de problemas:
kubectl logs -n ml-serving -l app=ml-inference --tail=100

5. Verificar o tamanho dos batches de inferência e considerar ajustar.

### ModelPerformanceDegradation

**Descrição**: Performance do modelo (precision, recall, f1-score) abaixo do limiar aceitável.

**Ações de Recuperação**:

1. Verificar dashboard "ML Model Health" para identificar qual métrica está degradada.

2. Analisar relatório de desempenho recente:
kubectl exec -n ml-serving <pod-ml-analysis> -- python /app/analyze_performance.py

3. Verificar logs do último job de avaliação:
kubectl logs -n ml-serving job/model-evaluation-<timestamp> -f

4. Ativar modelo fallback com melhor desempenho:
kubectl patch configmap ml-inference-config -n ml-serving --patch '{"data":{"ACTIVE_MODEL_VERSION":"<previous-stable-version>"}}'

5. Iniciar novo ciclo de treinamento com novos dados:
kubectl create job -n ml-serving model-retraining --from=cronjob/model-retraining-schedule

## Alertas de Segurança

### AdversarialAttackSuspected

**Descrição**: Múltiplas tentativas de possíveis ataques adversariais detectadas.

**Ações de Recuperação**:

1. Verificar logs de tentativas:
kubectl logs -n monitoring <prometheus-pod> -c prometheus | grep adversarial_attempts

2. Ativar modo de proteção avançada:
kubectl patch configmap ml-inference-config -n ml-serving --patch '{"data":{"DEFENSE_MODE":"advanced"}}'

3. Bloquear temporariamente IPs suspeitos:
kubectl exec -n ml-serving <security-pod> -- python /app/block_suspicious_ips.py

4. Extrair padrões de ataque para análise:
kubectl exec -n ml-serving <security-pod> -- python /app/extract_attack_patterns.py > attack_patterns.json

5. Notificar equipe de segurança com relatório detalhado.

## Alertas de Compliance

### RegulatoryComplianceIssue

**Descrição**: Problema de compliance com a Resolução BCB n° 403.

**Ações de Recuperação**:

1. Identificar qual artigo está não-conforme:
kubectl exec -n monitoring <prometheus-pod> -- curl -s http://localhost:9090/api/v1/query?query=bcb_403_compliance_score | jq

2. Verificar o último relatório de compliance:
kubectl exec -n ml-serving <compliance-pod> -- cat /app/reports/latest_compliance_report.json

3. Implementar ações corretivas conforme o artigo afetado:
- Para Art. 89 (Monitoramento em tempo real):
  ```
  kubectl scale deployment -n monitoring prometheus --replicas=2
  ```
- Para Art. 91 (Detecção de anomalias):
  ```
  kubectl patch configmap ml-analysis-config -n ml-serving --patch '{"data":{"ANOMALY_DETECTION_SENSITIVITY":"high"}}'
  ```

4. Notificar equipe jurídica e de compliance.

5. Agendar auditoria manual para verificar correção:
kubectl create job -n ml-serving compliance-audit-manual --from=cronjob/compliance-audit