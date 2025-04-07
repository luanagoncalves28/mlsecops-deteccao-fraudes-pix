# Infraestrutura como Código - Sistema de Detecção de Fraudes Pix

## Visão Geral

Este diretório contém a implementação completa da infraestrutura como código (IaC) para o sistema de detecção de fraudes Pix, utilizando Terraform como ferramenta principal. A infraestrutura é projetada para atender às exigências da Resolução BCB nº 403/2024 e proporcionar um ambiente seguro, escalável e conforme para operação do sistema.

## Estrutura do Diretório

```
terraform/
├── providers.tf        # Configuração dos provedores (GCP)
├── variables.tf        # Variáveis globais compartilhadas
├── outputs.tf          # Outputs globais do projeto
├── main.tf             # Arquivo principal de configuração
├── versions.tf         # Restrições de versão do Terraform e provedores
├── modulos/            # Componentes reutilizáveis e modulares
│   ├── armazenamento/  # Configuração de buckets e armazenamento
│   ├── gke/            # Configuração do Google Kubernetes Engine
│   ├── iam/            # Gerenciamento de identidade e acesso
│   ├── rede/           # Configuração de VPC, subnets e firewall
│   └── monitoring/     # Configuração de monitoramento e alertas
└── ambientes/          # Configurações específicas por ambiente
    ├── dev/            # Ambiente de desenvolvimento
    ├── homologacao/    # Ambiente de homologação
    └── producao/       # Ambiente de produção
```

## Componentes Principais

### Arquivos Base

- **providers.tf**: Define e configura o Google Cloud Platform como provedor principal, incluindo autenticação, região e projeto.
- **variables.tf**: Declara variáveis globais utilizadas em todo o projeto, como ID do projeto, região e outras configurações compartilhadas.
- **outputs.tf**: Exporta valores importantes gerados pela infraestrutura, como endpoints de serviços e URLs de acesso.
- **main.tf**: Orquestra os módulos principais e define recursos globais do projeto.
- **versions.tf**: Especifica as versões compatíveis do Terraform e dos provedores utilizados, garantindo reprodutibilidade.

### Módulos

Os módulos são projetados seguindo o princípio de responsabilidade única, permitindo reutilização em diferentes ambientes:

#### 1. Módulo de Armazenamento

Implementa a arquitetura medallion (Bronze, Silver, Gold) no Google Cloud Storage, com configurações específicas para cada camada:

- **Bronze**: Armazenamento de dados brutos com retenção configurável
- **Silver**: Dados processados e validados
- **Gold**: Dados agregados e prontos para consumo

Inclui também buckets especializados para artefatos de ML, logs, e backups.

#### 2. Módulo de GKE

Configura o Google Kubernetes Engine para orquestração de containers, incluindo:

- Cluster privado com controle de acesso IAM integrado
- Node pools especializados para diferentes cargas de trabalho (ML, serviços, etc.)
- Configuração de autoscaling baseado em métricas
- Integração com Workload Identity para autenticação segura

#### 3. Módulo de IAM

Implementa o princípio de menor privilégio através de:

- Contas de serviço dedicadas para cada componente
- Papéis customizados com permissões granulares
- Políticas de auditoria para monitoramento de acessos
- Integração com Secret Manager para gerenciamento seguro de credenciais

#### 4. Módulo de Rede

Estabelece uma infraestrutura de rede segura e isolada:

- VPC dedicada com segmentação por ambiente
- Subnets privadas para componentes internos
- Cloud NAT para acesso à internet controlado
- Regras de firewall explícitas seguindo abordagem deny-by-default

#### 5. Módulo de Monitoramento

Configura observabilidade completa da infraestrutura:

- Dashboards personalizados no Cloud Monitoring
- Alertas para anomalias e condições críticas
- Exportação de logs para análise de segurança
- Métricas customizadas para componentes específicos

### Ambientes

Cada ambiente (desenvolvimento, homologação, produção) possui configurações específicas que reutilizam os módulos base:

- **Desenvolvimento**: Recursos mínimos, otimizados para custo e iteração rápida
- **Homologação**: Configuração semelhante à produção, mas com escala reduzida
- **Produção**: Alta disponibilidade, redundância e escalabilidade máxima

## Decisões Arquiteturais

### Arquitetura Multi-Regional

Em produção, a infraestrutura é distribuída em múltiplas regiões (us-central1 e us-east1) para:

- Alta disponibilidade (99.99%)
- Disaster recovery automático
- Distribuição geográfica de cargas

### Segurança por Design

Todos os componentes seguem princípios de segurança avançados:

- Criptografia em trânsito e em repouso
- Validação de integridade para implantações
- Controle de acesso baseado em identidade
- Separação de ambientes com limites claros

### Otimização de Custos (FinOps)

A infraestrutura implementa práticas de FinOps:

- Dimensionamento preciso de recursos
- Autoscaling reativo e preditivo
- Exportação de métricas de utilização para análise de custos
- Configurações eficientes para recursos não-produtivos

## Requisitos Técnicos

- Terraform v1.5.0+
- Google Cloud SDK v461.0.0+
- Conta GCP com permissões adequadas
- Bucket para estado do Terraform já provisionado

## Integração com CI/CD

Esta infraestrutura é gerenciada através de pipelines CI/CD no GitHub Actions, que:

1. Validam alterações em pull requests
2. Executam testes automatizados em infra-as-code
3. Aplicam alterações após aprovação
4. Documentam mudanças e mantêm histórico de auditoria

---

Para questionamentos técnicos sobre esta infraestrutura, entre em contato:  
**Luana Gonçalves**  
lugonc.lga@gmail.com