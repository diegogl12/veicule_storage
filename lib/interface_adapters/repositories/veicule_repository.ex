defmodule VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository do
  @behaviour VeiculeStorage.Domain.Repositories.VeiculeRepositoryBehaviour

  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema
  alias VeiculeStorage.Domain.Entities.Veicule
  require Logger

  @impl true
  def get(id) do
    case Repo.get(VeiculeSchema, id) do
      nil -> {:error, :not_found}
      veicule_schema -> {:ok, to_veicule(veicule_schema)}
    end
  end

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

  @impl true
  def update(%Veicule{} = new_veicule) do
    with {:ok, current_veicule} <- get(new_veicule.id),
         changeset <- build_update_changeset(new_veicule, current_veicule),
         {:ok, veicule_updated} <- Repo.update(changeset) do
      {:ok, to_veicule(veicule_updated)}
    else
      {:error, error} ->
        Logger.error("Error on VeiculeRepository.update: #{inspect(error)}")
        {:error, error}
    end
  end

  defp to_schema(%Veicule{} = veicule) do
    %VeiculeSchema{
      id: veicule.id,
      brand: veicule.brand,
      model: veicule.model,
      year: veicule.year,
      color: veicule.color
    }
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

  defp build_update_changeset(%Veicule{} = new_veicule, %Veicule{} = current_veicule) do
    attrs = %{
      brand: new_veicule.brand,
      model: new_veicule.model,
      year: new_veicule.year,
      color: new_veicule.color
    }

    VeiculeSchema.changeset(to_schema(current_veicule), attrs)
  end
end
