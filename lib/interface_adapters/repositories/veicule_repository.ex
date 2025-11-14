defmodule VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository do
  @behaviour VeiculeStorage.Domain.Repositories.VeiculeRepositoryBehaviour

  import Ecto.Query

  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema

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
    # Usar changeset no create para consistência e validações futuras
    attrs = %{
      brand: veicule.brand,
      model: veicule.model,
      year: veicule.year,
      color: veicule.color
    }

    %VeiculeSchema{}
    |> VeiculeSchema.changeset(attrs)
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

  @impl true
  def get_all do
    Repo.all(VeiculeSchema)
    |> to_veicule_list()
  end

  @impl true
  def find_by_ids(ids) do
    Repo.all(from v in VeiculeSchema, where: v.id in ^ids, select: v)
    |> to_veicule_list()
  end

  defp to_veicule_list(veicules) do
    result = veicules
    |> Enum.map(&to_veicule/1)

    {:ok, result}
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
