defmodule VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository do
  @behaviour VeiculeStorage.Domain.Repositories.VeiculeRepositoryBehaviour

  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema
  alias VeiculeStorage.Domain.Entities.Veicule
  require Logger

  @impl true
  def create(%Veicule{} = veicule) do
    %VeiculeSchema{
      brand: veicule.brand,
      model: veicule.model,
      year: veicule.year,
      color: veicule.color
    }
    |> Repo.insert()
    |> case do
      {:ok, veicule_inserted} ->
        {:ok, to_veicule(veicule_inserted)}
      {:error, error} ->
        Logger.error("Error on VeiculeRepository.create: #{inspect(error)}")
        {:error, error}
    end
  end

  defp to_veicule(schema) do
    %Veicule{
      id: schema.id,
      brand: schema.brand,
      model: schema.model,
      year: schema.year,
      color: schema.color
    }
  end
end
