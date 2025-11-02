defmodule VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema do
  use VeiculeStorage.Infra.Repo.Schema
  import Ecto.Changeset

  schema "veicules" do
    field(:brand, :string)
    field(:model, :string)
    field(:year, :integer)
    field(:color, :string)

    timestamps()
  end

  @doc """
  Changeset function for VeiculeSchema.

  Em Elixir/Ecto, um changeset é uma estrutura de dados que representa mudanças
  a serem aplicadas em um schema. Ele valida e rastreia as alterações antes de
  persistir no banco de dados.

  A função `cast/3` pega os dados do segundo parâmetro e os converte para os
  campos especificados no terceiro parâmetro, criando um changeset.
  """
  def changeset(veicule_schema, attrs) do
    veicule_schema
    |> cast(attrs, [:brand, :model, :year, :color])
  end
end
