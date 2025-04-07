#!/bin/bash
# Script para remover recursos do ambiente de desenvolvimento
# Use: ./cleanup-dev.sh

echo "Removendo recursos do ambiente de desenvolvimento..."
cd terraform/ambientes/dev
terraform destroy -auto-approve

echo "Recursos removidos com sucesso!"