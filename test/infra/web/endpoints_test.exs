defmodule VeiculeStorage.Infra.Web.EndpointsTest do
  use ExUnit.Case, async: false
  import Plug.Test
  import Plug.Conn
  import Mimic

  alias VeiculeStorage.Domain.Entities.{Inventory, Sale, Veicule}
  alias VeiculeStorage.Infra.Web.Controllers.{InventoryController, SaleController, VeiculeController}
  alias VeiculeStorage.Infra.Web.Endpoints

  setup :set_mimic_global
  setup :verify_on_exit!

  @opts Endpoints.init([])

  describe "GET /api/health" do
    test "returns health check message" do
      # Arrange
      conn = conn(:get, "/api/health")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "Hello... All good!"
    end
  end

  describe "GET /api/docs" do
    test "returns Swagger UI HTML" do
      # Arrange
      conn = conn(:get, "/api/docs")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body =~ "swagger-ui"
      assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
    end
  end

  describe "GET /api/swagger.json" do
    test "returns OpenAPI specification" do
      # Arrange
      conn = conn(:get, "/api/swagger.json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200
      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]

      body = Jason.decode!(conn.resp_body)
      assert body["openapi"] == "3.0.0"
      assert body["info"]["title"] == "Veicule Storage API"
    end
  end

  describe "POST /api/veicules" do
    test "creates a veicule successfully" do
      # Arrange
      params = %{
        "brand" => "Toyota",
        "model" => "Corolla",
        "year" => "2023",
        "color" => "Prata"
      }

      veicule = %Veicule{
        id: "veicule-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      stub(VeiculeController, :create_veicule, fn ^params -> {:ok, veicule} end)

      conn =
        conn(:post, "/api/veicules", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 201
      assert get_resp_header(conn, "content-type") == ["application/json; charset=utf-8"]

      body = Jason.decode!(conn.resp_body)
      assert body["id"] == "veicule-123"
      assert body["brand"] == "Toyota"
    end

    test "returns error when creation fails" do
      # Arrange
      params = %{"invalid" => "data"}

      stub(VeiculeController, :create_veicule, fn ^params -> {:error, :invalid_params} end)

      conn =
        conn(:post, "/api/veicules", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400

      body = Jason.decode!(conn.resp_body)
      assert body["message"] =~ "Error creating veicule"
    end
  end

  describe "PUT /api/veicules/:id" do
    test "updates a veicule successfully" do
      # Arrange
      id = "veicule-123"
      params = %{
        "brand" => "Toyota",
        "model" => "Corolla",
        "year" => "2023",
        "color" => "Vermelho"
      }

      veicule = %Veicule{
        id: id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      stub(VeiculeController, :update_veicule, fn ^params, ^id -> {:ok, veicule} end)

      conn =
        conn(:put, "/api/veicules/#{id}", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert body["id"] == id
      assert body["color"] == "Vermelho"
    end

    test "returns error when update fails" do
      # Arrange
      id = "non-existent"
      params = %{"color" => "Azul"}

      stub(VeiculeController, :update_veicule, fn ^params, ^id -> {:error, :not_found} end)

      conn =
        conn(:put, "/api/veicules/#{id}", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400

      body = Jason.decode!(conn.resp_body)
      assert body["message"] =~ "Error updating veicule"
    end
  end

  describe "POST /api/inventories" do
    test "creates an inventory successfully" do
      # Arrange
      params = %{
        "veicule_id" => "veicule-123",
        "price" => "85000.00"
      }

      inventory = %Inventory{
        id: "inventory-456",
        veicule_id: "veicule-123",
        price: 85000.00
      }

      stub(InventoryController, :create_inventory, fn ^params -> {:ok, inventory} end)

      conn =
        conn(:post, "/api/inventories", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 201

      body = Jason.decode!(conn.resp_body)
      assert body["id"] == "inventory-456"
      assert body["veicule_id"] == "veicule-123"
    end

    test "returns error when creation fails" do
      # Arrange
      params = %{"invalid" => "data"}

      stub(InventoryController, :create_inventory, fn ^params -> {:error, :invalid_params} end)

      conn =
        conn(:post, "/api/inventories", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400
    end
  end

  describe "PUT /api/inventories/:id" do
    test "updates an inventory successfully" do
      # Arrange
      id = "inventory-123"
      params = %{"price" => "95000.00"}

      inventory = %Inventory{
        id: id,
        veicule_id: "veicule-123",
        price: 95000.00
      }

      stub(InventoryController, :update_inventory, fn ^params, ^id -> {:ok, inventory} end)

      conn =
        conn(:put, "/api/inventories/#{id}", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert body["id"] == id
      assert body["price"] == 95000.00
    end
  end

  describe "GET /api/inventories/all" do
    test "returns all inventories" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 85000.00},
        %Inventory{id: "inv-2", veicule_id: "v-2", price: 95000.00}
      ]

      stub(InventoryController, :get_all_inventories, fn -> {:ok, inventories} end)

      conn = conn(:get, "/api/inventories/all")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert length(body) == 2
      assert Enum.at(body, 0)["id"] == "inv-1"
    end

    test "returns error when fetching fails" do
      # Arrange
      stub(InventoryController, :get_all_inventories, fn -> {:error, :database_error} end)

      conn = conn(:get, "/api/inventories/all")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400
    end
  end

  describe "GET /api/inventories/to-sell" do
    test "returns inventories available to sell" do
      # Arrange
      inventories = [
        %{id: "inv-1", veicule_id: "v-1", price: 85000.00, status: "AVAILABLE"}
      ]

      stub(InventoryController, :get_all_to_sell, fn -> {:ok, inventories} end)

      conn = conn(:get, "/api/inventories/to-sell")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert length(body) == 1
      assert Enum.at(body, 0)["status"] == "AVAILABLE"
    end

    test "returns error when fetching fails" do
      # Arrange
      stub(InventoryController, :get_all_to_sell, fn -> {:error, :use_case_error} end)

      conn = conn(:get, "/api/inventories/to-sell")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400
    end
  end

  describe "GET /api/inventories/sold" do
    test "returns sold inventories" do
      # Arrange
      inventories = [
        %{id: "inv-1", veicule_id: "v-1", price: 85000.00, status: "SOLD"}
      ]

      stub(InventoryController, :get_all_sold, fn -> {:ok, inventories} end)

      conn = conn(:get, "/api/inventories/sold")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert length(body) == 1
      assert Enum.at(body, 0)["status"] == "SOLD"
    end

    test "returns error when fetching fails" do
      # Arrange
      stub(InventoryController, :get_all_sold, fn -> {:error, :use_case_error} end)

      conn = conn(:get, "/api/inventories/sold")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400
    end
  end

  describe "POST /api/sales/sell" do
    test "processes a sale successfully" do
      # Arrange
      params = %{
        "inventory_id" => "inventory-123",
        "payment_method" => "PIX",
        "payment_value" => "85000.00"
      }

      sale = %Sale{
        id: "sale-789",
        inventory_id: "inventory-123",
        payment_id: "payment-456",
        status: "IN_PROGRESS"
      }

      stub(SaleController, :sell, fn ^params -> {:ok, sale} end)

      conn =
        conn(:post, "/api/sales/sell", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 201

      body = Jason.decode!(conn.resp_body)
      assert body["id"] == "sale-789"
      assert body["status"] == "IN_PROGRESS"
    end

    test "returns error when sale fails" do
      # Arrange
      params = %{"invalid" => "data"}

      stub(SaleController, :sell, fn ^params -> {:error, :invalid_params} end)

      conn =
        conn(:post, "/api/sales/sell", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400

      body = Jason.decode!(conn.resp_body)
      assert body["message"] =~ "Error selling"
    end
  end

  describe "GET /api/sales/all" do
    test "returns all sales" do
      # Arrange
      sales = [
        %Sale{id: "sale-1", inventory_id: "inv-1", payment_id: "pay-1", status: "IN_PROGRESS"},
        %Sale{id: "sale-2", inventory_id: "inv-2", payment_id: "pay-2", status: "PAYMENT_COMPLETED"}
      ]

      stub(SaleController, :get_sales, fn -> {:ok, sales} end)

      conn = conn(:get, "/api/sales/all")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert length(body) == 2
      assert Enum.at(body, 0)["id"] == "sale-1"
      assert Enum.at(body, 1)["status"] == "PAYMENT_COMPLETED"
    end

    test "returns error when fetching fails" do
      # Arrange
      stub(SaleController, :get_sales, fn -> {:error, :database_error} end)

      conn = conn(:get, "/api/sales/all")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400
    end
  end

  describe "PUT /api/webhooks/sale-status-update" do
    test "updates sale status successfully" do
      # Arrange
      params = %{
        "id" => "sale-123",
        "inventory_id" => "inventory-456",
        "payment_id" => "payment-789",
        "status" => "PAYMENT_VALIDATED"
      }

      sale = %Sale{
        id: "sale-123",
        inventory_id: "inventory-456",
        payment_id: "payment-789",
        status: "PAYMENT_COMPLETED"
      }

      stub(SaleController, :sale_status_update, fn ^params -> {:ok, sale} end)

      conn =
        conn(:put, "/api/webhooks/sale-status-update", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200

      body = Jason.decode!(conn.resp_body)
      assert body["id"] == "sale-123"
      assert body["status"] == "PAYMENT_COMPLETED"
    end

    test "returns error when update fails" do
      # Arrange
      params = %{"id" => "non-existent", "status" => "INVALID"}

      stub(SaleController, :sale_status_update, fn ^params -> {:error, :not_found} end)

      conn =
        conn(:put, "/api/webhooks/sale-status-update", Jason.encode!(params))
        |> put_req_header("content-type", "application/json")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 400

      body = Jason.decode!(conn.resp_body)
      assert body["message"] =~ "Error updating sale status"
    end
  end

  describe "404 - Not Found" do
    test "returns 404 for unknown routes" do
      # Arrange
      conn = conn(:get, "/api/unknown-endpoint")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "Page not found"
    end

    test "returns 404 for POST on unknown routes" do
      # Arrange
      conn = conn(:post, "/api/unknown", "{}")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 404
    end

    test "returns 404 for PUT on unknown routes" do
      # Arrange
      conn = conn(:put, "/api/unknown/123", "{}")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 404
    end

    test "returns 404 for DELETE requests" do
      # Arrange
      conn = conn(:delete, "/api/veicules/123")

      # Act
      conn = Endpoints.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 404
    end
  end
end
