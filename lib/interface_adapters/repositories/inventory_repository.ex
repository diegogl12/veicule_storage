defmodule VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository do
  @behaviour VeiculeStorage.Domain.Repositories.InventoryRepositoryBehaviour

  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.InventorySchema
  alias VeiculeStorage.Domain.Entities.Inventory
  require Logger

  @impl true
  def create(%Inventory{} = inventory) do
    # Usar changeset também no create para consistência
    # Isso garante que validações futuras sejam aplicadas
    attrs = %{
      veicule_id: inventory.veicule_id,
      price: inventory.price
    }

    %InventorySchema{}
    |> InventorySchema.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, inventory_inserted} ->
        {:ok, to_inventory(inventory_inserted)}
      {:error, error} ->
        Logger.error("Error on InventoryRepository.create: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl true
  def update(%Inventory{} = inventory) do
    with {:ok, current_inventory} <- get(inventory.id),
         changeset <- build_update_changeset(inventory, current_inventory),
         {:ok, inventory_updated} <- Repo.update(changeset) do
      {:ok, to_inventory(inventory_updated)}
    else
      {:error, error} ->
        Logger.error("Error on InventoryRepository.update: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl true
  def get(id) do
    case Repo.get(InventorySchema, id) do
      nil -> {:error, :not_found}
      inventory_schema -> {:ok, to_inventory(inventory_schema)}
    end
  end

  @impl true
  def get_all() do
    Repo.all(InventorySchema)
    |> Enum.map(&to_inventory/1)
    |> case do
      [] -> {:ok, []}
      inventory_list -> {:ok, inventory_list}
    end
  end

  defp to_inventory(schema) do
    %Inventory{
      id: schema.id,
      veicule_id: schema.veicule_id,
      price: schema.price
    }
  end

  defp to_schema(%Inventory{} = inventory) do
    %InventorySchema{
      id: inventory.id,
      veicule_id: inventory.veicule_id,
      price: inventory.price
    }
  end

  defp build_update_changeset(%Inventory{} = new_inventory, %Inventory{} = current_inventory) do
    attrs = %{
      veicule_id: new_inventory.veicule_id,
      price: new_inventory.price
    }

    InventorySchema.changeset(to_schema(current_inventory), attrs)
  end
end
