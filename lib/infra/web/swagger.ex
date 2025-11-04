defmodule VeiculeStorage.Infra.Web.Swagger do
  @moduledoc """
  Módulo responsável por gerar a especificação OpenAPI (Swagger) da API.

  OpenAPI é um padrão de documentação de APIs REST que permite descrever
  endpoints, parâmetros, respostas e modelos de dados de forma estruturada.

  Este módulo usa um map aninhado que representa a estrutura JSON do OpenAPI 3.0,
  que é mais funcional do que usar classes ou builders imperativos.
  """

  @doc """
  Retorna a especificação completa da API no formato OpenAPI 3.0.

  A função `spec/0` é uma função pura que retorna sempre o mesmo resultado,
  sendo idempotente - característica importante em programação funcional.
  """
  def spec do
    %{
      openapi: "3.0.0",
      info: info(),
      servers: servers(),
      paths: paths(),
      components: components()
    }
  end

  defp info do
    %{
      title: "Veicule Storage API",
      description: "API para gerenciamento de veículos, inventário e vendas",
      version: "1.0.0",
      contact: %{
        name: "API Support",
        email: "support@veiculestorage.com"
      }
    }
  end

  defp servers do
    [
      %{
        url: "http://localhost:4000",
        description: "Servidor de desenvolvimento"
      }
    ]
  end

  defp paths do
    %{
      "/api/health" => health_endpoint(),
      "/api/veicules" => veicules_collection(),
      "/api/veicules/{id}" => veicules_item(),
      "/api/inventories" => inventories_collection(),
      "/api/inventories/{id}" => inventories_item(),
      "/api/inventories/all" => inventories_all(),
      "/api/inventories/to-sell" => inventories_to_sell(),
      "/api/inventories/sold" => inventories_sold(),
      "/api/sales/sell" => sales_sell(),
      "/api/sales/all" => sales_all(),
      "/api/webhooks/sale-status-update" => sale_status_webhook()
    }
  end

  defp health_endpoint do
    %{
      get: %{
        summary: "Health Check",
        description: "Verifica se a API está funcionando",
        tags: ["Health"],
        responses: %{
          "200" => %{
            description: "API funcionando corretamente",
            content: %{
              "text/plain" => %{
                schema: %{
                  type: "string",
                  example: "Hello... All good!"
                }
              }
            }
          }
        }
      }
    }
  end

  defp veicules_collection do
    %{
      post: %{
        summary: "Criar novo veículo",
        description: "Cria um novo veículo no sistema",
        tags: ["Veicules"],
        requestBody: %{
          required: true,
          content: %{
            "application/json" => %{
              schema: %{"$ref" => "#/components/schemas/VeiculeInput"}
            }
          }
        },
        responses: %{
          "201" => %{
            description: "Veículo criado com sucesso",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Veicule"}
              }
            }
          },
          "400" => %{
            description: "Erro ao criar veículo",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Error"}
              }
            }
          }
        }
      }
    }
  end

  defp veicules_item do
    %{
      put: %{
        summary: "Atualizar veículo",
        description: "Atualiza os dados de um veículo existente",
        tags: ["Veicules"],
        parameters: [
          %{
            name: "id",
            in: "path",
            required: true,
            description: "ID do veículo",
            schema: %{
              type: "string",
              format: "uuid"
            }
          }
        ],
        requestBody: %{
          required: true,
          content: %{
            "application/json" => %{
              schema: %{"$ref" => "#/components/schemas/VeiculeInput"}
            }
          }
        },
        responses: %{
          "200" => %{
            description: "Veículo atualizado com sucesso",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Veicule"}
              }
            }
          },
          "400" => %{
            description: "Erro ao atualizar veículo",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Error"}
              }
            }
          }
        }
      }
    }
  end

  defp inventories_collection do
    %{
      post: %{
        summary: "Criar inventário",
        description: "Adiciona um veículo ao inventário com seu preço",
        tags: ["Inventory"],
        requestBody: %{
          required: true,
          content: %{
            "application/json" => %{
              schema: %{"$ref" => "#/components/schemas/InventoryInput"}
            }
          }
        },
        responses: %{
          "201" => %{
            description: "Inventário criado com sucesso",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Inventory"}
              }
            }
          },
          "400" => %{
            description: "Erro ao criar inventário",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Error"}
              }
            }
          }
        }
      }
    }
  end

  defp inventories_item do
    %{
      put: %{
        summary: "Atualizar inventário",
        description: "Atualiza informações de um item do inventário",
        tags: ["Inventory"],
        parameters: [
          %{
            name: "id",
            in: "path",
            required: true,
            description: "ID do inventário",
            schema: %{
              type: "string",
              format: "uuid"
            }
          }
        ],
        requestBody: %{
          required: true,
          content: %{
            "application/json" => %{
              schema: %{"$ref" => "#/components/schemas/InventoryInput"}
            }
          }
        },
        responses: %{
          "200" => %{
            description: "Inventário atualizado com sucesso",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Inventory"}
              }
            }
          },
          "400" => %{
            description: "Erro ao atualizar inventário",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Error"}
              }
            }
          }
        }
      }
    }
  end

  defp inventories_all do
    %{
      get: %{
        summary: "Listar todo inventário",
        description: "Retorna todos os itens do inventário",
        tags: ["Inventory"],
        responses: %{
          "200" => %{
            description: "Lista de inventários",
            content: %{
              "application/json" => %{
                schema: %{
                  type: "array",
                  items: %{"$ref" => "#/components/schemas/Inventory"}
                }
              }
            }
          }
        }
      }
    }
  end

  defp inventories_to_sell do
    %{
      get: %{
        summary: "Veículos disponíveis para venda",
        description: "Retorna veículos que estão no inventário mas ainda não foram vendidos",
        tags: ["Inventory"],
        responses: %{
          "200" => %{
            description: "Lista de veículos disponíveis",
            content: %{
              "application/json" => %{
                schema: %{
                  type: "array",
                  items: %{"$ref" => "#/components/schemas/InventoryWithVeicule"}
                }
              }
            }
          }
        }
      }
    }
  end

  defp inventories_sold do
    %{
      get: %{
        summary: "Veículos vendidos",
        description: "Retorna veículos que já foram vendidos",
        tags: ["Inventory"],
        responses: %{
          "200" => %{
            description: "Lista de veículos vendidos",
            content: %{
              "application/json" => %{
                schema: %{
                  type: "array",
                  items: %{"$ref" => "#/components/schemas/InventoryWithVeicule"}
                }
              }
            }
          }
        }
      }
    }
  end

  defp sales_sell do
    %{
      post: %{
        summary: "Realizar venda",
        description: "Processa uma venda de veículo com pagamento",
        tags: ["Sales"],
        requestBody: %{
          required: true,
          content: %{
            "application/json" => %{
              schema: %{"$ref" => "#/components/schemas/SellInput"}
            }
          }
        },
        responses: %{
          "201" => %{
            description: "Venda realizada com sucesso",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Sale"}
              }
            }
          },
          "400" => %{
            description: "Erro ao processar venda",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Error"}
              }
            }
          }
        }
      }
    }
  end

  defp sales_all do
    %{
      get: %{
        summary: "Listar vendas",
        description: "Retorna todas as vendas realizadas",
        tags: ["Sales"],
        responses: %{
          "200" => %{
            description: "Lista de vendas",
            content: %{
              "application/json" => %{
                schema: %{
                  type: "array",
                  items: %{"$ref" => "#/components/schemas/Sale"}
                }
              }
            }
          }
        }
      }
    }
  end

  defp sale_status_webhook do
    %{
      put: %{
        summary: "Webhook de atualização de pagamento",
        description: "Endpoint para receber notificações de mudança de status do pagamento",
        tags: ["Webhooks"],
        requestBody: %{
          required: true,
          content: %{
            "application/json" => %{
              schema: %{"$ref" => "#/components/schemas/SaleStatusUpdate"}
            }
          }
        },
        responses: %{
          "200" => %{
            description: "Status atualizado com sucesso",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Sale"}
              }
            }
          },
          "400" => %{
            description: "Erro ao atualizar status",
            content: %{
              "application/json" => %{
                schema: %{"$ref" => "#/components/schemas/Error"}
              }
            }
          }
        }
      }
    }
  end

  defp components do
    %{
      schemas: %{
        Veicule: veicule_schema(),
        VeiculeInput: veicule_input_schema(),
        Inventory: inventory_schema(),
        InventoryInput: inventory_input_schema(),
        InventoryWithVeicule: inventory_with_veicule_schema(),
        Sale: sale_schema(),
        SellInput: sell_input_schema(),
        SaleStatusUpdate: sale_status_update_schema(),
        Error: error_schema()
      }
    }
  end

  defp veicule_schema do
    %{
      type: "object",
      properties: %{
        id: %{
          type: "string",
          format: "uuid",
          description: "ID único do veículo"
        },
        brand: %{
          type: "string",
          description: "Marca do veículo",
          example: "Toyota"
        },
        model: %{
          type: "string",
          description: "Modelo do veículo",
          example: "Corolla"
        },
        year: %{
          type: "integer",
          description: "Ano do veículo",
          example: 2023
        },
        color: %{
          type: "string",
          description: "Cor do veículo",
          example: "Prata"
        }
      },
      required: ["id", "brand", "model", "year", "color"]
    }
  end

  defp veicule_input_schema do
    %{
      type: "object",
      properties: %{
        brand: %{
          type: "string",
          description: "Marca do veículo",
          example: "Toyota"
        },
        model: %{
          type: "string",
          description: "Modelo do veículo",
          example: "Corolla"
        },
        year: %{
          type: "integer",
          description: "Ano do veículo",
          example: 2023
        },
        color: %{
          type: "string",
          description: "Cor do veículo",
          example: "Prata"
        }
      },
      required: ["brand", "model", "year", "color"]
    }
  end

  defp inventory_schema do
    %{
      type: "object",
      properties: %{
        id: %{
          type: "string",
          format: "uuid",
          description: "ID do inventário"
        },
        veicule_id: %{
          type: "string",
          format: "uuid",
          description: "ID do veículo"
        },
        price: %{
          type: "number",
          format: "float",
          description: "Preço do veículo",
          example: 85000.00
        }
      },
      required: ["id", "veicule_id", "price"]
    }
  end

  defp inventory_input_schema do
    %{
      type: "object",
      properties: %{
        veicule_id: %{
          type: "string",
          format: "uuid",
          description: "ID do veículo"
        },
        price: %{
          type: "number",
          format: "float",
          description: "Preço do veículo",
          example: 85000.00
        }
      },
      required: ["veicule_id", "price"]
    }
  end

  defp inventory_with_veicule_schema do
    %{
      type: "object",
      properties: %{
        id: %{
          type: "string",
          format: "uuid",
          description: "ID do inventário"
        },
        veicule_id: %{
          type: "string",
          format: "uuid",
          description: "ID do veículo"
        },
        price: %{
          type: "number",
          format: "float",
          description: "Preço do veículo",
          example: 85000.00
        },
        veicule: %{
          "$ref" => "#/components/schemas/Veicule"
        }
      }
    }
  end

  defp sale_schema do
    %{
      type: "object",
      properties: %{
        id: %{
          type: "string",
          format: "uuid",
          description: "ID da venda"
        },
        inventory_id: %{
          type: "string",
          format: "uuid",
          description: "ID do inventário vendido"
        },
        payment_id: %{
          type: "string",
          format: "uuid",
          description: "ID do pagamento"
        },
        status: %{
          type: "string",
          description: "Status da venda",
          enum: ["IN_PROGRESS", "PAYMENT_COMPLETED", "PAYMENT_CANCELLED", "ERROR"],
          example: "IN_PROGRESS"
        }
      },
      required: ["id", "inventory_id", "payment_id", "status"]
    }
  end

  defp sell_input_schema do
    %{
      type: "object",
      properties: %{
        inventory_id: %{
          type: "string",
          format: "uuid",
          description: "ID do inventário a ser vendido"
        },
        payment_method: %{
          type: "string",
          description: "Método de pagamento",
          example: "PIX"
        },
        payment_value: %{
          type: "number",
          format: "float",
          description: "Valor do pagamento",
          example: 85000.00
        }
      },
      required: ["inventory_id", "payment_method", "payment_value"]
    }
  end

  defp sale_status_update_schema do
    %{
      type: "object",
      properties: %{
        id: %{
          type: "string",
          format: "uuid",
          description: "ID da venda"
        },
        status: %{
          type: "string",
          description: "Novo status da venda",
          enum: ["PAYMENT_VALIDATED", "PAYMENT_CANCELLED"],
          example: "PAYMENT_VALIDATED"
        }
      },
      required: ["id", "status"]
    }
  end

  defp error_schema do
    %{
      type: "object",
      properties: %{
        message: %{
          type: "string",
          description: "Mensagem de erro",
          example: "Error creating veicule: :invalid_data"
        }
      },
      required: ["message"]
    }
  end
end
