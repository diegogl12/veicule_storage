defmodule VeiculeStorage.InterfaceAdapters.Repositories.Schemas.InventorySchema do
  use VeiculeStorage.Infra.Repo.Schema
  import Ecto.Changeset

  schema "inventories" do
    field(:veicule_id, :binary_id)
    field(:price, :float)

    timestamps()
  end

  def changeset(inventory_schema, attrs) do
    inventory_schema
    |> cast(attrs, [:veicule_id, :price])
  end
end
