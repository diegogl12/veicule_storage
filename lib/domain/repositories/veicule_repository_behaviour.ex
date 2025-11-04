defmodule VeiculeStorage.Domain.Repositories.VeiculeRepositoryBehaviour do
  @callback create(Veicule.t()) :: {:ok, Veicule.t()} | {:error, any()}
  @callback update(Veicule.t()) :: {:ok, Veicule.t()} | {:error, any()}
  @callback get(String.t()) :: {:ok, Veicule.t()} | {:error, any()}
  @callback get_all() :: {:ok, [Veicule.t()]} | {:error, any()}
  @callback find_by_ids([String.t()]) :: {:ok, [Veicule.t()]} | {:error, any()}
end
