defmodule VeiculeStorage.Domain.Entities.Inventory do
  alias VeiculeStorage.Domain.Entities.Veicule
  @derive {Jason.Encoder, only: [:id, :veicule_id, :price, :veicule]}
  defstruct [:id, :veicule_id, :price, :veicule]

  @type t :: %__MODULE__{
          id: String.t(),
          veicule_id: String.t(),
          price: float(),
          veicule: Veicule.t() | nil
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
