defmodule VeiculeStorage.Infra.Web.Endpoints do
  use Plug.Router
  require Logger

  alias VeiculeStorage.Infra.Web.Controllers.VeiculeController
  alias VeiculeStorage.Infra.Web.Controllers.InventoryController
  alias VeiculeStorage.Infra.Web.Controllers.SaleController

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)

  plug(:dispatch)

  get "/api/health" do
    send_resp(conn, 200, "Hello... All good!")
  end

  post "/api/veicules" do
    case VeiculeController.create_veicule(conn.body_params) do
      {:ok, veicule} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(veicule))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error creating veicule: #{inspect(error)}"}))
    end
  end

  put "/api/veicules/:id" do
    case VeiculeController.update_veicule(conn.body_params, conn.params["id"]) do
      {:ok, veicule} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(veicule))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error updating veicule: #{inspect(error)}"}))
    end
  end

  post "api/inventories" do
    case InventoryController.create_inventory(conn.body_params) do
      {:ok, inventory} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(inventory))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error creating inventory: #{inspect(error)}"}))
    end
  end

  put "/api/inventories/:id" do
    case InventoryController.update_inventory(conn.body_params, conn.params["id"]) do
      {:ok, inventory} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(inventory))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error updating inventory: #{inspect(error)}"}))
    end
  end

  get "/api/inventories/all" do
    case InventoryController.get_all_inventories() do
      {:ok, inventories} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(inventories))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error getting inventories: #{inspect(error)}"}))
    end
  end

  post "/api/sales/sell" do
    case SaleController.sell(conn.body_params) do
      {:ok, sale} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(201, Jason.encode!(sale))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error selling: #{inspect(error)}"}))
    end
  end

  get "/api/sales/all" do
    case SaleController.get_sales() do
      {:ok, sales} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(sales))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error getting sales: #{inspect(error)}"}))
    end
  end

  put "/api/webhooks/sale-status-update" do
    case SaleController.sale_status_update(conn.body_params) do
      {:ok, sale} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(sale))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error updating sale status: #{inspect(error)}"}))
    end
  end

  get "/api/inventories/to-sell" do
    case InventoryController.get_all_to_sell() do
      {:ok, inventories} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(inventories))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error getting inventories to sell: #{inspect(error)}"}))
    end
  end

  get "/api/inventories/sold" do
    case InventoryController.get_all_sold() do
      {:ok, inventories} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(inventories))
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Jason.encode!(%{message: "Error getting inventories sold: #{inspect(error)}"}))
    end
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end
end
