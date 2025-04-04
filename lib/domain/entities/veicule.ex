defmodule VeiculeStorage.Domain.Entities.Veicule do
  @derive {Jason.Encoder, only: [:id, :brand, :model, :year, :color]}
  defstruct [:id, :brand, :model, :year, :color]

  @type t :: %__MODULE__{
          id: String.t(),
          brand: String.t(),
          model: String.t(),
          year: integer(),
          color: String.t()
        }

  def new(attrs) do
    veicule =
      struct(
        __MODULE__,
        Map.merge(attrs, %{
          created_at: NaiveDateTime.utc_now()
        })
      )

    {:ok, veicule}
  end
end
