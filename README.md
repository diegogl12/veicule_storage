[![Coverage Status](https://coveralls.io/repos/github/diegogl12/veicule_storage/badge.svg?branch=main)](https://coveralls.io/github/diegogl12/veicule_storage?branch=main)
# 🚗 Veicule Storage API

## :pencil: Descrição do Projeto
<p align="left">Este projeto tem como objetivo concluir as entregas do Tech Challenge do curso de Software Architecture da Pós Graduação da FIAP 2024/2025.
Este repositório constrói um serviço de gerenciamento de veículos, inventário e vendas, seguindo os princípios de Clean Architecture.</p>

## :computer: Tecnologias Utilizadas
- **Linguagem:** Elixir
- **Framework Web:** Plug + Cowboy
- **Banco de Dados:** PostgreSQL 15
- **Containerização:** Docker
- **Orquestração:** Kubernetes (Minikube)
- **Documentação:** OpenAPI 3.0 (Swagger)

## :hammer: Detalhes do Serviço

Este serviço oferece uma API REST completa para:
- **Gerenciamento de Veículos:** Cadastro e atualização de veículos
- **Controle de Inventário:** Gestão de estoque com preços
- **Processamento de Vendas:** Fluxo completo de venda com integração de pagamento
- **Consultas:** Listagem de veículos disponíveis e vendidos

### 🏗️ Arquitetura

O projeto segue **Clean Architecture** com as seguintes camadas:
- **Domain:** Entidades e regras de negócio
- **Use Cases:** Casos de uso da aplicação
- **Interface Adapters:** Controllers, DTOs e Repositories
- **Infrastructure:** Web, Database e Gateways externos

## :hammer_and_wrench: Execução do Projeto

### Pré-requisitos
- Docker e Docker Compose
- Elixir 1.15+ (para desenvolvimento local)
- Minikube (para deploy em Kubernetes)
- Make

### 🐳 Opção 1: Docker Compose (Desenvolvimento Local)

```bash
# 1. Clone o projeto
git clone <repository-url>
cd veicule_store

# 2. Suba os containers
make up-compose

# 3. Acesse a aplicação
# API: http://localhost:4000
# Swagger UI: http://localhost:4000/api/docs
```

### ☸️ Opção 2: Kubernetes (Minikube)

```bash
# 1. Inicie o Minikube
minikube start

# 2. Deploy completo (PostgreSQL + Aplicação)
make up-kube

# 3. Aguarde os pods ficarem prontos
kubectl get pods -w

# 4. Acesse via port-forward
kubectl port-forward service/veicule-storage-service 4000:80

# 5. Acesse a aplicação
# API: http://localhost:4000
# Swagger UI: http://localhost:4000/api/docs
```

### 🗑️ Limpeza

```bash
# Docker Compose
docker-compose down -v

# Kubernetes
make down-kube
```

## 📚 Documentação da API

### Swagger UI Interativo
Acesse a documentação completa e teste os endpoints diretamente no navegador:

```
http://localhost:4000/api/docs
```

### Especificação OpenAPI (JSON)
Para importar em ferramentas como Postman ou Insomnia:

```
http://localhost:4000/api/swagger.json
```

## 🔌 Endpoints Disponíveis

### Health Check
- `GET /api/health` - Verifica se a API está funcionando

### Documentação
- `GET /api/docs` - Interface Swagger UI
- `GET /api/swagger.json` - Especificação OpenAPI 3.0

### Veículos
- `POST /api/veicules` - Criar novo veículo
- `PUT /api/veicules/:id` - Atualizar veículo

### Inventário
- `POST /api/inventories` - Adicionar veículo ao inventário
- `PUT /api/inventories/:id` - Atualizar item do inventário
- `GET /api/inventories/all` - Listar todo o inventário
- `GET /api/inventories/to-sell` - Listar veículos disponíveis para venda
- `GET /api/inventories/sold` - Listar veículos vendidos

### Vendas
- `POST /api/sales/sell` - Realizar uma venda
- `GET /api/sales/all` - Listar todas as vendas

### Webhooks
- `PUT /api/webhooks/sale-status-update` - Atualizar status do pagamento

## 📋 Comandos Make Disponíveis

```bash
# Docker Compose
make up-compose      # Sobe a aplicação com Docker Compose

# Kubernetes
make up-kube         # Deploy completo no Kubernetes
make down-kube       # Remove todos os recursos do Kubernetes

# SQS (Legacy)
make create_message  # Cria mensagem no SQS local
```

## 🏛️ Clean Architecture - Estrutura do Projeto

O projeto segue rigorosamente os princípios da **Clean Architecture** (Uncle Bob), organizando o código em camadas concêntricas onde as dependências apontam sempre para dentro, do mais externo para o mais interno.

### 📐 Camadas da Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │           INTERFACE ADAPTERS                      │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │              USE CASES                      │  │  │
│  │  │  ┌───────────────────────────────────────┐  │  │  │
│  │  │  │           DOMAIN                      │  │  │  │
│  │  │  │  • Entities                           │  │  │  │
│  │  │  │  • Business Rules                     │  │  │  │
│  │  │  │  • Repository Interfaces (Behaviours) │  │  │  │
│  │  │  │  • Gateway Interfaces (Behaviours)    │  │  │  │
│  │  │  └───────────────────────────────────────┘  │  │  │
│  │  │                                              │  │  │
│  │  │  • VeiculesToSell                           │  │  │
│  │  │  • VeiculesSold                             │  │  │
│  │  │  • Sell                                     │  │  │
│  │  │  • SalePaymentUpdate                        │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                                                     │  │
│  │  • Controllers (Internal)                          │  │
│  │  • DTOs (Data Transfer Objects)                    │  │
│  │  • Repository Implementations                      │  │
│  │  • Gateway Implementations                         │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  • Web (Endpoints, Controllers HTTP)                    │
│  • Database (Ecto Repo, Schemas)                        │
│  • External Services                                    │
└─────────────────────────────────────────────────────────┘
```

### 📂 Estrutura de Diretórios

```elixir
lib/
├── domain/                           # 🔵 CAMADA DE DOMÍNIO (Núcleo)
│   ├── entities/                     # Entidades de negócio (regras que sempre são verdadeiras)
│   │   ├── veicule.ex               # Entidade Veículo
│   │   ├── inventory.ex             # Entidade Inventário
│   │   ├── sale.ex                  # Entidade Venda
│   │   └── payment.ex               # Entidade Pagamento
│   │
│   ├── repositories/                 # Interfaces (Behaviours) dos repositórios
│   │   ├── veicule_repository_behaviour.ex
│   │   ├── inventory_repository_behaviour.ex
│   │   ├── sale_repository_behaviour.ex
│   │   └── payment_repository_behaviour.ex
│   │
│   └── gateways/                     # Interfaces (Behaviours) de gateways externos
│       └── payment_gateway_behaviour.ex
│
├── use_cases/                        # 🟢 CAMADA DE CASOS DE USO (Regras de aplicação)
│   ├── veicules_to_sell.ex          # UC: Listar veículos disponíveis
│   ├── veicules_sold.ex             # UC: Listar veículos vendidos
│   ├── sell.ex                      # UC: Processar venda
│   └── sale_payment_update.ex       # UC: Atualizar status de pagamento
│
├── interface_adapters/               # 🟡 CAMADA DE ADAPTADORES DE INTERFACE
│   ├── controllers/                  # Controllers internos (orquestram use cases)
│   │   ├── veicule_internal_controller.ex
│   │   ├── inventory_internal_controller.ex
│   │   └── sale_internal_controller.ex
│   │
│   ├── dtos/                        # Data Transfer Objects (conversão de dados)
│   │   ├── veicule_dto.ex
│   │   ├── inventory_dto.ex
│   │   ├── sale_dto.ex
│   │   └── sell_input_dto.ex
│   │
│   ├── repositories/                 # Implementações dos repositórios
│   │   ├── veicule_repository.ex
│   │   ├── inventory_repository.ex
│   │   ├── sale_repository.ex
│   │   ├── payment_repository.ex
│   │   └── schemas/                 # Schemas Ecto (detalhes de persistência)
│   │       ├── VeiculeSchema.ex
│   │       ├── InventorySchema.ex
│   │       ├── SaleSchema.ex
│   │       └── PaymentSchema.ex
│   │
│   └── gateways/                    # Implementações de gateways externos
│       └── clients/
│           └── mercadopago.ex
│
└── infra/                           # 🔴 CAMADA DE INFRAESTRUTURA (Frameworks & Drivers)
    ├── web/                         # Framework Web (Plug/Cowboy)
    │   ├── endpoints.ex             # Definição de rotas HTTP
    │   ├── swagger.ex               # Especificação OpenAPI
    │   ├── swagger_ui.ex            # Interface Swagger UI
    │   └── controllers/             # Controllers HTTP (entrada da requisição)
    │       ├── veicule_controller.ex
    │       ├── inventory_controller.ex
    │       └── sale_controller.ex
    │
    └── repo/                        # Framework de Banco de Dados (Ecto)
        ├── veicule_storage_repo.ex  # Configuração do Ecto Repo
        └── schema.ex                # Schema base
```

### 🎯 Princípios SOLID Aplicados

| Sigla | Princípio | Aplicação no Projeto |
|-------|-----------|---------------------|
| **S** | Single Responsibility | Cada Use Case tem uma única responsabilidade (ex: `Sell.ex` apenas processa vendas) |
| **O** | Open/Closed | Behaviours permitem extensão sem modificação (ex: `PaymentGatewayBehaviour` aceita novos gateways) |
| **L** | Liskov Substitution | Implementações de repositórios são intercambiáveis via Behaviours (ex: trocar `VeiculeRepository` por mock em testes) |
| **I** | Interface Segregation | Behaviours específicos por domínio (ex: `VeiculeRepositoryBehaviour` só com métodos de veículos) |
| **D** | Dependency Inversion | Use Cases dependem de abstrações (Behaviours), não de implementações concretas (ex: `Sell` recebe behaviour, não Ecto) |

## 🧪 Testes

```bash
# Rodar todos os testes
mix test

# Rodar com coverage
mix coveralls

# Rodar testes específicos
mix test test/interface_adapters/controllers/
```

## :page_with_curl: Documentações Adicionais

- [Documentação Kubernetes](.kube/README.md)
- [Documentação Swagger](SWAGGER.md)
- [OpenAPI Specification](http://localhost:4000/api/swagger.json)

## :busts_in_silhouette: Autor

| [<img loading="lazy" src="https://avatars.githubusercontent.com/u/16946021?v=4" width=115><br><sub>Diego Gomes - RM358549</sub>](https://github.com/diegogl12) |
| :---: |
