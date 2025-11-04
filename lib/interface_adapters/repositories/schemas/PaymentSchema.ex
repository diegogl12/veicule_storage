defmodule VeiculeStorage.InterfaceAdapters.Repositories.Schemas.PaymentSchema do
  use VeiculeStorage.Infra.Repo.Schema
  import Ecto.Changeset

  schema "payments" do
    field(:payment_method, :string)
    field(:payment_value, :float)
    field(:status, :string)
    field(:payment_date, :naive_datetime)

    timestamps()
  end

  @doc """
  Changeset function for PaymentSchema.

  Similar ao VeiculeSchema, esta função cria um changeset para rastrear
  mudanças antes de persistir no banco de dados.

  `cast/3` converte os dados externos (attrs) para os campos do schema.
  """
  def changeset(payment_schema, attrs) do
    payment_schema
    |> cast(attrs, [:payment_method, :payment_value, :status, :payment_date])
  end
end
