defmodule VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository do
  @behaviour VeiculeStorage.Domain.Repositories.SaleRepositoryBehaviour

  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.SaleSchema
  alias VeiculeStorage.Domain.Entities.Sale

  require Logger

  @impl true
  def create(%Sale{} = sale) do
    attrs = %{
      inventory_id: sale.inventory_id,
      payment_id: sale.payment_id,
      status: sale.status
    }

    %SaleSchema{}
    |> SaleSchema.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, sale_inserted} ->
        {:ok, to_sale(sale_inserted)}
      {:error, error} ->
        Logger.error("Error on SaleRepository.create: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl true
  def update(%Sale{} = sale) do
    with {:ok, current_sale} <- get(sale.id),
         changeset <- build_update_changeset(sale, current_sale),
         {:ok, sale_updated} <- Repo.update(changeset) do
      {:ok, to_sale(sale_updated)}
    else
      {:error, error} ->
        Logger.error("Error on SaleRepository.update: #{inspect(error)}")
        {:error, error}
    end
  end

  @impl true
  def get_by_inventory_id(inventory_id) do
    case Repo.get_by(SaleSchema, inventory_id: inventory_id) do
      nil -> {:error, :not_found}
      sale_schema -> {:ok, to_sale(sale_schema)}
    end
  end

  @impl true
  def get(id) do
    case Repo.get(SaleSchema, id) do
      nil -> {:error, :not_found}
      sale_schema -> {:ok, to_sale(sale_schema)}
    end
  end

  @impl true
  def get_all() do
    Repo.all(SaleSchema)
    |> Enum.map(&to_sale/1)
    |> case do
      [] -> {:ok, []}
      sales_list -> {:ok, sales_list}
    end
  end

  defp to_sale(schema) do
    %Sale{
      id: schema.id,
      inventory_id: schema.inventory_id,
      payment_id: schema.payment_id,
      status: schema.status
    }
  end

  defp build_update_changeset(%Sale{} = sale, %Sale{} = current_sale) do
    attrs = %{status: sale.status}
    SaleSchema.changeset(to_schema(current_sale), attrs)
  end

  defp to_schema(%Sale{} = sale) do
    %SaleSchema{
      id: sale.id,
      inventory_id: sale.inventory_id,
      payment_id: sale.payment_id,
      status: sale.status
    }
  end
end
