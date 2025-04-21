# Módulo VPC

Cria:

* VPC custom (sem sub‑redes automáticas).
* Sub‑rede única (/16) para ambiente dev.
* Firewall mínimo (SSH + health checks).
* Router + Cloud NAT para saída internet.

## Variáveis

| Nome | Descrição | Default |
|------|-----------|---------|
| project_id | Projeto GCP | – |
| region | Região (ex. southamerica‑east1) | – |
| network_name | Prefixo dos recursos de rede | mlsecpix-vpc |
| subnet_cidr | Range CIDR da sub‑rede | 10.0.0.0/16 |
| environment | dev / stg / prod | dev |