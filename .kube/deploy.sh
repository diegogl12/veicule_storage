#!/bin/bash

# Script para fazer deploy completo no Minikube
# Uso: ./deploy.sh

set -e  # Para na primeira falha

echo "🚀 Iniciando deploy no Minikube..."

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verifica se o Minikube está rodando
echo -e "${BLUE}📋 Verificando Minikube...${NC}"
if ! minikube status > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Minikube não está rodando. Iniciando...${NC}"
    minikube start
else
    echo -e "${GREEN}✅ Minikube já está rodando${NC}"
fi

# 2. Aplica os recursos do PostgreSQL
echo -e "\n${BLUE}🐘 Criando PostgreSQL...${NC}"
kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres-pvc.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

# 3. Aguarda o PostgreSQL ficar pronto
echo -e "${YELLOW}⏳ Aguardando PostgreSQL ficar pronto...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

# 4. Aplica os recursos da aplicação
echo -e "\n${BLUE}📦 Criando aplicação...${NC}"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# 5. Aguarda a aplicação ficar pronta
echo -e "${YELLOW}⏳ Aguardando aplicação ficar pronta...${NC}"
kubectl wait --for=condition=ready pod -l app=veicule-storage-app --timeout=300s

# 6. Mostra o status
echo -e "\n${GREEN}✅ Deploy concluído!${NC}"
echo -e "\n${BLUE}📊 Status dos recursos:${NC}"
kubectl get all

# 7. Pega a URL do service
echo -e "\n${BLUE}🌐 URL da aplicação:${NC}"
SERVICE_URL=$(minikube service veicule-storage-service --url)
echo -e "${GREEN}$SERVICE_URL${NC}"

# 8. Testa o health check
echo -e "\n${BLUE}🏥 Testando health check...${NC}"
sleep 5  # Aguarda um pouco mais
if curl -s "$SERVICE_URL/api/health" > /dev/null; then
    echo -e "${GREEN}✅ Aplicação está saudável!${NC}"
else
    echo -e "${YELLOW}⚠️  Health check falhou. Verificando logs...${NC}"
    kubectl logs -l app=veicule-storage-app --tail=20
fi

# 9. Informações úteis
echo -e "\n${BLUE}📝 Comandos úteis:${NC}"
echo "  Ver logs:        kubectl logs -l app=veicule-storage-app -f"
echo "  Ver pods:        kubectl get pods"
echo "  Ver services:    kubectl get services"
echo "  Acessar app:     $SERVICE_URL"
echo "  Swagger UI:      $SERVICE_URL/api/docs"
echo "  Port-forward:    kubectl port-forward service/veicule-storage-service 4000:80"
echo ""
echo -e "${GREEN}🎉 Tudo pronto!${NC}"

