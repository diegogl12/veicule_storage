defmodule VeiculeStorage.Domain.Repositories.SaleRepositoryBehaviour do
  alias VeiculeStorage.Domain.Entities.Sale

  @callback create(Sale.t()) :: {:ok, Sale.t()} | {:error, any()}
  @callback update(Sale.t()) :: {:ok, Sale.t()} | {:error, any()}
  @callback get_by_inventory_id(String.t()) :: {:ok, Sale.t()} | {:error, any()}
  @callback get(String.t()) :: {:ok, Sale.t()} | {:error, any()}
  @callback get_all() :: {:ok, [Sale.t()]} | {:error, any()}
end
