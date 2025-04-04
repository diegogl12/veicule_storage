defmodule VeiculeStorage.InterfaceAdapters.Repositories.Schemas.PaymentSchema do
  use VeiculeStorage.Infra.Repo.Schema

  schema "payments" do
    field(:payment_method, :string)
    field(:payment_value, :float)
    field(:status, :string)
    field(:payment_date, :naive_datetime)

    timestamps(type: :utc_datetime)
  end
end
