defmodule VeiculeStorage.InterfaceAdapters.Controllers.InventoryInternalController do
  alias VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository
  alias VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO
  alias VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository
  alias VeiculeStorage.UseCases.VeiculesToSell
  alias VeiculeStorage.UseCases.VeiculesSold

  def create(%InventoryDTO{} = dto) do
    with {:ok, inventory_domain} <- InventoryDTO.to_domain(dto),
         {:ok, _veicule} <- VeiculeRepository.get(inventory_domain.veicule_id),
         {:ok, inventory} <- InventoryRepository.create(inventory_domain) do
      {:ok, inventory}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def update(%InventoryDTO{} = dto) do
    with {:ok, inventory_domain} <- InventoryDTO.to_domain(dto),
         {:ok, _veicule} <- VeiculeRepository.get(inventory_domain.veicule_id),
         {:ok, inventory} <- InventoryRepository.update(inventory_domain) do
      {:ok, inventory}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def get_all() do
    with {:ok, inventory_list} <- InventoryRepository.get_all() do
      {:ok, inventory_list}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def get_all_to_sell() do
    with {:ok, inventories} <- VeiculesToSell.execute(VeiculeRepository, InventoryRepository, SaleRepository),
         inventories_dto <- Enum.map(inventories, &InventoryDTO.from_domain/1) do
      {:ok, inventories_dto}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def get_all_sold() do
    with {:ok, inventories} <- VeiculesSold.execute(VeiculeRepository, InventoryRepository, SaleRepository),
         inventories_dto <- Enum.map(inventories, &InventoryDTO.from_domain/1) do
      {:ok, inventories_dto}
    else
      {:error, error} -> {:error, error}
    end
  end
end
