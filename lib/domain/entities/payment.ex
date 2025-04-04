defmodule VeiculeStorage.Domain.Entities.Payment do
  @derive {Jason.Encoder, only: [:id, :payment_method, :payment_value, :status, :payment_date]}
  defstruct [:id, :payment_method, :payment_value, :status, :payment_date]

  @type t :: %__MODULE__{
          id: String.t(),
          payment_method: String.t(),
          payment_value: float(),
          status: String.t(),
          payment_date: NaiveDateTime.t()
        }

  def new(attrs) do
    payment =
      struct(
        __MODULE__,
        Map.merge(attrs, %{
          created_at: NaiveDateTime.utc_now()
        })
      )

    {:ok, payment}
  end
end
