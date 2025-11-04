# 📚 Documentação da API - Swagger/OpenAPI

Este projeto inclui documentação completa da API usando o padrão **OpenAPI 3.0** (Swagger).

## 🚀 Como Acessar a Documentação

### Opção 1: Swagger UI Integrado (Recomendado)

A forma mais fácil de visualizar e testar a API:

```
http://localhost:4000/api/docs
```

Esta interface permite:
- ✅ Visualizar todos os endpoints
- ✅ Ver modelos de dados (schemas)
- ✅ Testar requisições diretamente no navegador
- ✅ Ver exemplos de request/response
- ✅ Validar payloads

### Opção 2: Especificação JSON

Para importar em ferramentas externas (Postman, Insomnia, etc):

```
http://localhost:4000/api/swagger.json
```

## 📋 Endpoints Documentados

### Health Check
- `GET /api/health` - Verifica se a API está funcionando

### Veículos
- `POST /api/veicules` - Criar novo veículo
- `PUT /api/veicules/{id}` - Atualizar veículo

### Inventário
- `POST /api/inventories` - Adicionar veículo ao inventário
- `PUT /api/inventories/{id}` - Atualizar item do inventário
- `GET /api/inventories/all` - Listar todo inventário
- `GET /api/inventories/to-sell` - Veículos disponíveis para venda
- `GET /api/inventories/sold` - Veículos vendidos

### Vendas
- `POST /api/sales/sell` - Realizar venda
- `GET /api/sales/all` - Listar todas as vendas

### Webhooks
- `PUT /api/webhooks/sale-status-update` - Atualizar status do pagamento

## 🛠️ Usando com Ferramentas Externas

### Postman

1. Abra o Postman
2. Clique em **Import**
3. Cole a URL: `http://localhost:4000/api/swagger.json`
4. A coleção completa será importada automaticamente

### Insomnia

1. Abra o Insomnia
2. Clique em **Create** → **Import From** → **URL**
3. Cole: `http://localhost:4000/api/swagger.json`

### VS Code (REST Client)

Você pode usar a especificação para gerar requisições automaticamente.

## 📖 Estrutura do Código

### Arquivos Criados

```
lib/infra/web/
├── swagger.ex       # Especificação OpenAPI 3.0
├── swagger_ui.ex    # Template HTML do Swagger UI
└── endpoints.ex     # Rotas (incluindo /api/docs e /api/swagger.json)
```

### Como Funciona (Teoria Elixir)

#### `swagger.ex`
- Define a especificação da API usando **maps aninhados**
- Cada função retorna um fragmento da especificação
- Abordagem **funcional e composicional**: funções pequenas que se combinam
- Usa o padrão **builder** de forma funcional (sem mutação de estado)

```elixir
def spec do
  %{
    openapi: "3.0.0",
    info: info(),        # Composição de funções
    servers: servers(),
    paths: paths(),
    components: components()
  }
end
```

#### `swagger_ui.ex`
- Retorna HTML como **string heredoc** (""")
- Abordagem funcional: sem templates engines complexos
- O HTML carrega o Swagger UI via CDN
- **Função pura**: sempre retorna o mesmo resultado

#### `endpoints.ex`
- Usa **pattern matching** nas rotas (GET, POST, PUT)
- **Pipe operator** (`|>`) para compor respostas HTTP
- Endpoint `/api/docs` serve o HTML do Swagger UI
- Endpoint `/api/swagger.json` serve a especificação em JSON

## 🎯 Exemplos de Uso

### Criar um Veículo

**Request:**
```bash
curl -X POST http://localhost:4000/api/veicules \
  -H "Content-Type: application/json" \
  -d '{
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2023,
    "color": "Prata"
  }'
```

**Response:**
```json
{
  "id": "uuid-gerado",
  "brand": "Toyota",
  "model": "Corolla",
  "year": 2023,
  "color": "Prata"
}
```

### Adicionar ao Inventário

**Request:**
```bash
curl -X POST http://localhost:4000/api/inventories \
  -H "Content-Type: application/json" \
  -d '{
    "veicule_id": "uuid-do-veiculo",
    "price": 85000.00
  }'
```

### Realizar Venda

**Request:**
```bash
curl -X POST http://localhost:4000/api/sales/sell \
  -H "Content-Type: application/json" \
  -d '{
    "inventory_id": "uuid-do-inventario",
    "payment_method": "PIX",
    "payment_value": 85000.00
  }'
```

## 🔍 Validação de Schemas

A documentação Swagger inclui validação de tipos para todos os campos:

- **Strings**: brand, model, color, payment_method, status
- **Integers**: year
- **Floats**: price, payment_value
- **UUIDs**: id, veicule_id, inventory_id, payment_id

## 💡 Dicas

1. **Desenvolvimento**: Sempre consulte `/api/docs` antes de fazer integrações
2. **Testes**: Use o Swagger UI para testar endpoints sem precisar escrever código
3. **Documentação Viva**: A spec é gerada em tempo de execução, sempre atualizada
4. **CI/CD**: Você pode exportar o JSON para validação automática de contratos

## 🚨 Troubleshooting

### Swagger UI não carrega
- Verifique se o servidor está rodando: `http://localhost:4000/api/health`
- Confirme que tem acesso à internet (para carregar CDN do Swagger UI)

### JSON está vazio
- Certifique-se que o módulo `VeiculeStorage.Infra.Web.Swagger` está compilado
- Reinicie o servidor: `mix phx.server` ou `iex -S mix`

## 📚 Referências

- [OpenAPI Specification 3.0](https://swagger.io/specification/)
- [Swagger UI Documentation](https://swagger.io/tools/swagger-ui/)
- [Swagger Editor Online](https://editor.swagger.io/)

