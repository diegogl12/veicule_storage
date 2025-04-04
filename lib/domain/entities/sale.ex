defmodule VeiculeStorage.Domain.Entities.Sale do
  @derive {Jason.Encoder, only: [:id, :inventory_id, :payment_id, :status]}
  defstruct [:id, :inventory_id, :payment_id, :status]

  @type t :: %__MODULE__{
          id: String.t(),
          inventory_id: String.t(),
          payment_id: String.t(),
          status: String.t()
        }

  def new(attrs) do
    sale =
      struct(
        __MODULE__,
        Map.merge(attrs, %{
          created_at: NaiveDateTime.utc_now()
        })
      )

    {:ok, sale}
  end
end
