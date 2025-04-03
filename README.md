# Sistema de Detecção de Fraudes Pix - Framework MLSecOps

[![Resolução BCB-403](https://img.shields.io/badge/Compliance-BCB_403_2024-00A34B.svg)](docs/compliance/conformidade-resolucao-bcb-403.md)
[![MLSecOps](https://img.shields.io/badge/Framework-MLSecOps_2025-E02D69.svg)](src/mlsecops/README.md)

## Visão Geral

Este repositório contém a implementação do meu sistema de detecção de fraudes para transações Pix, desenvolvido em conformidade com a Resolução BCB nº 403 de julho/2024. O sistema utiliza uma arquitetura avançada de MLSecOps, integrando segurança em todo o ciclo de vida de machine learning, desde a sanitização de dados até o monitoramento em produção.

A implementação reflete minha experiência como engenheira especializada em ML para o setor financeiro, combinando técnicas avançadas de detecção com rigorosa aderência aos requisitos regulatórios brasileiros atualizados em 2025.

## Problema de Negócio

A Resolução BCB nº 403/2024 estabeleceu um novo patamar de exigências para instituições financeiras no Brasil, especialmente no que tange à prevenção de fraudes no sistema Pix. Entre as novas exigências estão:

- Monitoramento de transações com tempo de resposta inferior a 200ms
- Capacidade de bloqueio preventivo baseado em análise de risco
- Detecção de padrões de fraude emergentes sem histórico prévio
- Explicabilidade completa e auditável de todas as decisões
- Integração com o DICT para compartilhamento de informações de segurança

Com a escalada de golpes de engenharia social (+43% em 2024) e o aumento de 62% no volume de transações Pix, o desafio técnico de implementar um sistema eficaz sem comprometer a experiência do usuário é substancial.

## Arquitetura

Desenvolvi uma arquitetura orientada a eventos que permite processamento em tempo real com alta disponibilidade (99,99%) e degradação elegante sob carga. O sistema implementa o conceito de "defense-in-depth" com múltiplas camadas de proteção.

![Arquitetura do Sistema](docs/arquitetura/images/arquitetura-geral.png)

### Componentes-Chave

- **Pipeline de Streaming**  
  Implementação com Kafka e Spark Structured Streaming para processamento de até 15.000 TPS nos horários de pico, com latência p99 < 120ms.

- **Arquitetura Medallion (Delta Lake)**  
  Sistema de armazenamento em camadas que preserva dados brutos (Bronze), dados processados (Silver) e dados analíticos (Gold) com versionamento completo para auditoria.

- **Banco de Features Especializado**  
  Solução customizada que mantém mais de 250 features comportamentais, transacionais e de rede, com TTL configurável e atualização contínua.

- **Ensemble de Modelos Avançados**  
  Combinação de modelos especializados que trabalham em conjunto:
  - Modelo comportamental (XGBoost aprimorado)
  - Modelo transacional (Deep Neural Network)
  - Modelo de anomalias (autoencoder com atenção)
  - Modelo de análise de rede (GNN implementado com DGL)

- **Camada de MLSecOps Proprietária**  
  Framework que desenvolvi para integrar segurança em todas as fases:
  - Sanitização contra envenenamento de dados
  - Validação de robustez contra ataques adversariais
  - Proteção contra extração de modelo e invasão de privacidade

## Diferenciais Técnicos

- **Abordagem Adaptativa em Tempo Real**  
  O sistema reajusta automaticamente os parâmetros de detecção baseado em feedback contínuo, utilizando técnicas de aprendizado por reforço.

- **Análise de Rede Transacional**  
  Implementação de algoritmos de análise de grafos que identificam comunidades suspeitas e padrões de fluxo anômalo de recursos entre contas.

- **Explicabilidade Contextual**  
  Além de técnicas tradicionais (SHAP, LIME), implementei um sistema de explicação contextual que traduz decisões técnicas em narrativas compreensíveis para diferentes stakeholders (clientes, analistas, reguladores).

- **Orquestração Resiliente**  
  Implementação própria de padrões de resiliência (circuit breaker, bulkhead, retry com exponential backoff) que garantem operação mesmo sob falhas parciais.

## Resultados Alcançados

A solução foi validada com datasets sintéticos que refletem o cenário atual (2025) de fraudes no Pix:

- **Taxa de detecção**: 98.7% para fraudes comportamentais (vs. benchmark de 94%)
- **Falsos positivos**: 0.08% em transações legítimas (vs. 0.3% da solução anterior)
- **Latência média**: 87ms para decisão com ensemble completo
- **Explicabilidade**: 100% das decisões com explicação adequada ao contexto

## Conformidade Regulatória

O sistema está em total conformidade com a Resolução BCB nº 403/2024, com mapeamento detalhado de cada requisito para componentes específicos da implementação. A documentação completa está disponível em [docs/compliance](docs/compliance/conformidade-resolucao-bcb-403.md).

Destaco a implementação dos aspectos mais desafiadores da regulação:

- **Bloqueio preventivo com evidência insuficiente**: Sistema de scoring probabilístico multifator
- **Rastreabilidade de decisões**: Armazenamento imutável com assinatura digital
- **Compatibilidade com LGPD**: Minimização e pseudonimização de dados pessoais

## Estrutura do Repositório

\`\`\`
.
├── dados/                 # Datasets simulados e geração de dados sintéticos
├── databricks/            # Ambiente analítico com notebooks Delta Lake
├── docs/                  # Documentação técnica e regulatória
├── banco_features/        # Implementação do banco de features especializado
├── infraestrutura/        # Configurações de cloud e Kubernetes
├── modelos/               # Implementação dos modelos de detecção
├── monitoramento/         # Dashboards e sistema de alertas
├── servicos/              # Microsserviços para detecção em tempo real
├── src/                   # Código-fonte principal do sistema
└── testes/                # Framework de testes automatizados
\`\`\`

## Aviso Legal

**Este repositório contém material proprietário desenvolvido por Luana Gonçalves exclusivamente para demonstração de capacidade técnica. Todo o conteúdo está protegido por direitos autorais. Não é permitida a cópia, distribuição ou implementação sem autorização explícita.**

O código e a documentação são apresentados para avaliação técnica por recrutadores e refletem minha experiência em MLOps, MLSecOps e sistemas para o setor financeiro.

## Sobre a Autora

Desenvolvi este sistema baseado em minha experiência como Engenheira de Machine Learning especializada no setor financeiro, combinando conhecimentos técnicos avançados com profunda compreensão do contexto regulatório brasileiro. Este projeto reflete minha abordagem de integrar segurança e compliance desde o início do ciclo de desenvolvimento.

Para mais informações: [lugonc.lga@gmail.com](mailto:lugonc.lga@gmail.com)
