defmodule VeiculeStorage.InterfaceAdapters.Repositories.Schemas.SaleSchema do
  use VeiculeStorage.Infra.Repo.Schema
  import Ecto.Changeset

  schema "sales" do
    field(:inventory_id, :binary_id)
    field(:payment_id, :binary_id)
    field(:status, :string)

    timestamps()
  end

  def changeset(sale_schema, attrs) do
    sale_schema
    |> cast(attrs, [:inventory_id, :payment_id, :status])
  end
end
