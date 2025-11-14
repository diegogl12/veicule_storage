defmodule VeiculeStorage.Domain.Repositories.InventoryRepositoryBehaviour do
  alias VeiculeStorage.Domain.Entities.Inventory

  @callback create(Inventory.t()) :: {:ok, Inventory.t()} | {:error, any()}
  @callback get(String.t()) :: {:ok, Inventory.t()} | {:error, any()}
  @callback get_all() :: {:ok, [Inventory.t()]} | {:error, any()}
  @callback update(Inventory.t()) :: {:ok, Inventory.t()} | {:error, any()}
end
