# 🚀 Deploy no Kubernetes (Minikube)

Este diretório contém todos os arquivos necessários para fazer deploy da aplicação no Kubernetes.

## 📁 Arquivos

### PostgreSQL
- `postgres-secret.yaml` - Credenciais do banco de dados
- `postgres-pvc.yaml` - Volume persistente para dados
- `postgres-deployment.yaml` - Deployment do PostgreSQL
- `postgres-service.yaml` - Service interno do PostgreSQL

### Aplicação
- `deployment.yaml` - Deployment da aplicação Elixir
- `service.yaml` - Service para expor a aplicação

### Utilitários
- `deploy.sh` - Script automatizado para deploy completo
- `README.md` - Este arquivo

---

## 🎯 Deploy Rápido (Recomendado)

```bash
# 1. Torna o script executável
chmod +x deploy.sh

# 2. Executa o deploy completo
./deploy.sh
```

O script faz tudo automaticamente:
- ✅ Inicia o Minikube (se necessário)
- ✅ Cria o PostgreSQL com volume persistente
- ✅ Aguarda o banco ficar pronto
- ✅ Faz deploy da aplicação
- ✅ Testa o health check
- ✅ Mostra a URL de acesso

---

## 📝 Deploy Manual (Passo a Passo)

### 1. Inicie o Minikube

```bash
minikube start
```

### 2. Deploy do PostgreSQL

```bash
# Aplica os recursos na ordem correta
kubectl apply -f .kube/postgres-secret.yaml
kubectl apply -f .kube/postgres-pvc.yaml
kubectl apply -f .kube/postgres-deployment.yaml
kubectl apply -f .kube/postgres-service.yaml

# Aguarda o PostgreSQL ficar pronto
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

# Verifica se está rodando
kubectl get pods -l app=postgres
```

### 3. Deploy da Aplicação

```bash
# Aplica os recursos da aplicação
kubectl apply -f .kube/deployment.yaml
kubectl apply -f .kube/service.yaml

# Aguarda a aplicação ficar pronta
kubectl wait --for=condition=ready pod -l app=veicule-storage-app --timeout=300s

# Verifica se está rodando
kubectl get pods -l app=veicule-storage-app
```

### 4. Acesse a Aplicação

```bash
# Opção A: Usando minikube service (abre no navegador)
minikube service veicule-storage-service

# Opção B: Pega a URL
minikube service veicule-storage-service --url

# Opção C: Port-forward para localhost
kubectl port-forward service/veicule-storage-service 4000:80
# Acesse: http://localhost:4000
```

---

## 🔍 Comandos Úteis

### Verificar Status

```bash
# Ver todos os recursos
kubectl get all

# Ver pods
kubectl get pods

# Ver services
kubectl get services

# Ver volumes
kubectl get pvc
```

### Ver Logs

```bash
# Logs da aplicação
kubectl logs -l app=veicule-storage-app -f

# Logs do PostgreSQL
kubectl logs -l app=postgres -f

# Logs de um pod específico
kubectl logs <nome-do-pod>
```

### Testar Conexão

```bash
# Health check
URL=$(minikube service veicule-storage-service --url)
curl $URL/api/health

# Swagger UI
open $URL/api/docs

# Criar um veículo
curl -X POST $URL/api/veicules \
  -H "Content-Type: application/json" \
  -d '{
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2023,
    "color": "Prata"
  }'
```

### Entrar no PostgreSQL

```bash
# Entra no pod do PostgreSQL
kubectl exec -it $(kubectl get pod -l app=postgres -o jsonpath='{.items[0].metadata.name}') -- psql -U postgres -d veicule_storage_dev

# Dentro do psql:
\dt          # Lista tabelas
\d veicules  # Descreve tabela veicules
SELECT * FROM veicules;
\q           # Sair
```

### Debug

```bash
# Descrever um pod (ver eventos)
kubectl describe pod <nome-do-pod>

# Entrar em um pod
kubectl exec -it <nome-do-pod> -- /bin/sh

# Ver eventos do cluster
kubectl get events --sort-by=.metadata.creationTimestamp

# Ver uso de recursos
kubectl top pods
```

---

## 🔄 Atualizar a Aplicação

### Opção 1: Rebuild e Redeploy

```bash
# 1. Faz build da nova imagem
docker build -t diegogl12/veicule-storage:latest .

# 2. Faz push para o Docker Hub
docker push diegogl12/veicule-storage:latest

# 3. Força o Kubernetes a baixar a nova imagem
kubectl rollout restart deployment veicule-storage-deployment

# 4. Acompanha o rollout
kubectl rollout status deployment veicule-storage-deployment
```

### Opção 2: Atualizar Configurações

```bash
# Edita o deployment
kubectl edit deployment veicule-storage-deployment

# Ou reaplica o arquivo
kubectl apply -f deployment.yaml
```

---

## 🗑️ Limpar Tudo

### Deletar Apenas a Aplicação

```bash
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
```

### Deletar Tudo (Incluindo PostgreSQL)

```bash
# Deleta todos os recursos
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f postgres-deployment.yaml
kubectl delete -f postgres-service.yaml
kubectl delete -f postgres-pvc.yaml
kubectl delete -f postgres-secret.yaml

# Ou use um script
kubectl delete -f .
```

### Parar o Minikube

```bash
# Para o Minikube (preserva os dados)
minikube stop

# Deleta o cluster completamente
minikube delete
```

---

## 🐘 Sobre o PostgreSQL

### Configurações

- **Versão:** PostgreSQL 15
- **Usuário:** postgres
- **Senha:** postgres
- **Database:** veicule_storage_dev
- **Porta:** 5432 (interna)
- **Storage:** 1GB persistente

### Persistência de Dados

Os dados do PostgreSQL são armazenados em um **PersistentVolume**, o que significa:
- ✅ Dados sobrevivem a reinicializações do pod
- ✅ Dados sobrevivem a `kubectl delete pod`
- ❌ Dados são perdidos se você deletar o PVC ou o Minikube

### Acessar o Banco Diretamente

```bash
# Port-forward do PostgreSQL
kubectl port-forward service/postgres-service 5432:5432

# Em outro terminal, conecte com psql
psql -h localhost -U postgres -d veicule_storage_dev
# Senha: postgres
```

---

## 🔐 Segurança

### ⚠️ Importante para Produção

Os secrets neste exemplo estão em **plain text** para fins educacionais. 

**Em produção, NUNCA faça isso!** Use:
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [External Secrets Operator](https://external-secrets.io/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- Secrets gerenciados pela cloud (AWS Secrets Manager, GCP Secret Manager, etc.)

### Criar Secrets Manualmente (Mais Seguro)

```bash
# Ao invés de aplicar o arquivo, crie o secret diretamente
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USER=postgres \
  --from-literal=POSTGRES_PASSWORD=sua-senha-segura \
  --from-literal=POSTGRES_DB=veicule_storage_dev

# Depois delete o arquivo postgres-secret.yaml
rm postgres-secret.yaml
```

---

## 📊 Arquitetura

```
┌─────────────────────────────────────────┐
│           Minikube Cluster              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   veicule-storage-service       │   │
│  │   (NodePort: 30000)             │   │
│  └────────────┬────────────────────┘   │
│               │                         │
│  ┌────────────▼────────────────────┐   │
│  │  veicule-storage-deployment     │   │
│  │  (Replicas: 1)                  │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │  Container: Elixir App   │   │   │
│  │  │  Port: 4000              │   │   │
│  │  └──────────┬───────────────┘   │   │
│  └─────────────┼─────────────────────┘ │
│                │                         │
│                │ Conecta via             │
│                │ postgres-service        │
│                │                         │
│  ┌─────────────▼─────────────────────┐ │
│  │   postgres-service                │ │
│  │   (ClusterIP: interno)            │ │
│  └────────────┬──────────────────────┘ │
│               │                         │
│  ┌────────────▼──────────────────────┐ │
│  │  postgres-deployment              │ │
│  │  (Replicas: 1)                    │ │
│  │  ┌────────────────────────────┐   │ │
│  │  │  Container: PostgreSQL 15  │   │ │
│  │  │  Port: 5432                │   │ │
│  │  └────────────┬───────────────┘   │ │
│  └───────────────┼───────────────────┘ │
│                  │                      │
│  ┌───────────────▼───────────────────┐ │
│  │  postgres-pvc                     │ │
│  │  (PersistentVolumeClaim: 1GB)    │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎓 Para o Trabalho Acadêmico

Este setup demonstra:
- ✅ Deploy de aplicação stateless (Elixir)
- ✅ Deploy de aplicação stateful (PostgreSQL)
- ✅ Uso de Secrets para credenciais
- ✅ Uso de PersistentVolumes para dados
- ✅ Services para comunicação interna
- ✅ Health checks (liveness/readiness probes)
- ✅ Resource limits e requests
- ✅ Exposição externa via NodePort

---

## 🆘 Troubleshooting

### Problema: Pods não iniciam

```bash
# Veja os eventos
kubectl describe pod <nome-do-pod>

# Veja os logs
kubectl logs <nome-do-pod>
```

### Problema: Aplicação não conecta no banco

```bash
# Verifica se o PostgreSQL está rodando
kubectl get pods -l app=postgres

# Verifica os endpoints do service
kubectl get endpoints postgres-service

# Testa conexão de dentro de um pod
kubectl run curl-test --image=curlimages/curl -it --rm -- sh
# Dentro: curl http://postgres-service:5432
```

### Problema: Dados foram perdidos

```bash
# Verifica se o PVC existe
kubectl get pvc

# Verifica se está bound
kubectl describe pvc postgres-pvc
```

---

## 📚 Referências

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [PostgreSQL on Kubernetes](https://kubernetes.io/docs/tutorials/stateful-application/postgres/)

