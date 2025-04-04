defmodule VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema do
  use VeiculeStorage.Infra.Repo.Schema

  schema "veicules" do
    field(:brand, :string)
    field(:model, :string)
    field(:year, :integer)
    field(:color, :string)

    timestamps()
  end
end
