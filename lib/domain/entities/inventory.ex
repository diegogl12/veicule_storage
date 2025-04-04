defmodule VeiculeStorage.Domain.Entities.Inventory do
  @derive {Jason.Encoder, only: [:id, :veicule_id, :price]}
  defstruct [:id, :veicule_id, :price]

  @type t :: %__MODULE__{
          id: String.t(),
          veicule_id: String.t(),
          price: float()
        }

  def new(attrs) do
    inventory =
      struct(
        __MODULE__,
        Map.merge(attrs, %{
          created_at: NaiveDateTime.utc_now()
        })
      )

    {:ok, inventory}
  end
end
