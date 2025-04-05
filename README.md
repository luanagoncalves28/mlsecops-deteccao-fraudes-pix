# Sistema de Detecção de Fraudes Pix com MLSecOps

[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-Pipeline-blue)](https://github.com/username/pix-fraud-detection-mlsecops/actions/workflows/ci-api-deployment.yml)
[![Treinamento de Modelo](https://img.shields.io/badge/Modelo-Treinamento-green)](https://github.com/username/pix-fraud-detection-mlsecops/actions/workflows/ci-model-training.yml)
[![Status do Projeto](https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow)]()

## 🔍 Sobre este Projeto

Este repositório contém um **projeto fictício demonstrativo** que implementa um sistema de detecção de fraudes em tempo real para transações Pix, desenvolvido em conformidade com a Resolução BCB nº 403 de 22/07/2024. O objetivo é demonstrar minha capacidade de traduzir problemas complexos de negócio em soluções tecnológicas robustas usando MLOps e MLSecOps.

> **Nota para Recrutadores:** Este projeto foi criado como uma demonstração de habilidades técnicas e conhecimento em engenharia de ML, MLOps e MLSecOps. Embora seja um projeto fictício, ele segue as melhores práticas da indústria e demonstra como eu abordaria desafios semelhantes em um ambiente de produção real.

## 🌟 Abordagem e Metodologia

Minha metodologia para resolver problemas complexos de negócio se baseia em quatro etapas principais:

1️⃣ **Compreensão Profunda do Domínio de Negócio**  
Análise e interpretação detalhada de requisitos regulatórios e de negócio (Fase 1)

2️⃣ **Tradução de Requisitos em Especificações Técnicas**  
Transformação de requisitos em especificações técnicas implementáveis (Fase 2)

3️⃣ **Design de Arquiteturas Seguras e Escaláveis**  
Criação de uma arquitetura moderna, segura e conformidade regulatória (Fase 3)

4️⃣ **Implementação End-to-End com MLOps/MLSecOps**  
Desenvolvimento completo com práticas integradas de DevOps, MLOps e segurança (Fase 4)

## 🏗️ Arquitetura do Sistema

O sistema utiliza uma arquitetura de referência moderna baseada em:

![Arquitetura do Sistema](docs/architecture/images/architecture-diagram.png)

### Principais Componentes

* **Ingestão e Processamento**: Apache Kafka e Spark Structured Streaming para processamento em tempo real
* **Armazenamento**: Delta Lake com arquitetura medallion (Bronze/Silver/Gold) para governança de dados
* **ML & MLOps**: MLflow para rastreabilidade completa do ciclo de vida de modelos
* **Infraestrutura**: Google Cloud Platform (GKE) e Terraform para infraestrutura como código
* **Monitoramento**: Prometheus e Grafana para observabilidade abrangente

[Veja a documentação completa de arquitetura](docs/architecture/architecture-overview.md)

## 🛡️ MLSecOps Integrado

Este projeto implementa práticas avançadas de MLSecOps, integrando segurança em todas as etapas do ciclo de vida de ML:

* **Validação e Sanitização de Dados**: Proteção contra envenenamento de dados
* **Segurança de Modelos**: Proteção contra ataques adversariais
* **Detecção de Drift**: Monitoramento contínuo da performance do modelo
* **Explicabilidade**: SHAP/LIME para interpretabilidade regulatória
* **Auditoria Completa**: Rastreabilidade de todas as decisões automatizadas

[Saiba mais sobre as práticas de MLSecOps](docs/compliance/mlsecops-overview.md)

## 🚀 Aplicações em Diferentes Indústrias

Embora este projeto demonstre capacidades no setor financeiro, a mesma metodologia e abordagem técnica são aplicáveis em outras indústrias:

| Indústria | Aplicação Potencial | Benefícios |
|-----------|---------------------|------------|
| **Saúde** | Detecção de fraudes em planos de saúde | Redução de custos, conformidade com regulamentações da saúde |
| **Varejo** | Detecção de fraudes em transações e-commerce | Redução de chargebacks, melhoria na experiência do cliente |
| **Manufatura** | Identificação de anomalias em processos produtivos | Redução de desperdício, melhoria na qualidade |
| **Logística** | Detecção de padrões atípicos em cadeias de suprimentos | Otimização de rotas, redução de fraudes em entregas |

## 📂 Estrutura do Repositório

```
pix-fraud-detection-mlsecops/
├── .github/              # Configurações de CI/CD e templates
├── data/                 # Dados (bronze, silver, gold)
├── databricks/           # Notebooks e jobs do Databricks
├── docs/                 # Documentação extensiva
│   ├── architecture/     # Design e diagramas de arquitetura
│   ├── compliance/       # Documentação de conformidade
│   └── ...
├── feature_store/        # Camada de feature store
├── infrastructure/       # IaC (Terraform, Kubernetes)
├── models/               # Código de modelos de ML
├── monitoring/           # Configurações de monitoramento
├── services/             # Microsserviços
├── src/                  # Código-fonte principal
│   ├── data/             # Processamento de dados
│   ├── features/         # Engenharia de features
│   ├── models/           # Implementações de modelos
│   └── mlsecops/         # Utilitários de MLSecOps
└── tests/                # Testes automatizados
```

## 🚦 Como Explorar este Projeto

Para recrutadores e avaliadores técnicos, sugiro explorar o projeto nesta ordem:

1. [Análise de Compliance e Jurídica](docs/compliance/analise_compliance_e_juridica.md) - Compreensão do contexto regulatório
2. [Problema de Negócio](docs/business/problema_de_negocio.md) - Entendimento do problema a ser resolvido
3. [Especificações Técnicas](docs/specifications/especificacoes_tecnicas.md) - Tradução de requisitos em especificações
4. [Design Arquitetural](docs/architecture/architecture-overview.md) - Arquitetura proposta
5. [Implementação MLOps](docs/mlops/mlops_ciclo_vida.md) - Ciclo de vida de ML em produção
6. [Implementação FinOps](docs/finops/FinOps_ciclo_vida.md) - Otimização de custos e recursos

## 💼 Demonstração de Capacidades Profissionais

Este projeto demonstra minhas capacidades como Engenheira de ML/MLOps/MLSecOps em:

* **Tradução de Problemas de Negócio em Soluções Técnicas**: Análise regulatória e de requisitos
* **Arquitetura de Sistemas de ML Escaláveis**: Microsserviços orientados a eventos
* **Implementação de MLOps End-to-End**: Ciclo de vida completo de ML automatizado
* **Integração de Segurança no Processo de ML**: Abordagem MLSecOps abrangente
* **Otimização de Custos com FinOps**: Equilíbrio entre performance e eficiência de recursos
* **Documentação e Comunicação Técnica**: Explicação clara de conceitos complexos

## 📫 Contato

Estou aberta a oportunidades e discussões sobre como posso agregar valor à sua organização com minhas habilidades em ML/MLOps/MLSecOps.

* **Email**: lugonc.lga@gmail.com
* **LinkedIn**: [linkedin.com/in/luanagoncalves05](https://www.linkedin.com/in/luanagoncalves05/)
* **GitHub**: [github.com/luanagbmartins](https://github.com/luanagbmartins)

## 📝 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.