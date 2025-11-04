defmodule VeiculeStorage.Infra.Web.Controllers.InventoryController do
  alias VeiculeStorage.InterfaceAdapters.Controllers.InventoryInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO

  require Logger

  def create_inventory(params) do
    Logger.info("Creating inventory: #{inspect(params)}")

    with {:ok, dto} <- InventoryDTO.from_map(params),
         {:ok, inventory} <- InventoryInternalController.create(dto) do
      {:ok, inventory}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def update_inventory(params, id) do
    with {:ok, dto_with_id} <- Map.put(params, "id", id) |> InventoryDTO.from_map(),
         {:ok, inventory} <- InventoryInternalController.update(dto_with_id) do
      {:ok, inventory}
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_all_inventories() do
    with {:ok, inventory_list} <- InventoryInternalController.get_all() do
      {:ok, inventory_list}
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_all_to_sell() do
    with {:ok, inventories} <- InventoryInternalController.get_all_to_sell() do
      {:ok, inventories}
    else
      {:error, error} -> {:error, error}
    end
  end

  def get_all_sold() do
    with {:ok, inventories} <- InventoryInternalController.get_all_sold() do
      {:ok, inventories}
    else
      {:error, error} -> {:error, error}
    end
  end
end
