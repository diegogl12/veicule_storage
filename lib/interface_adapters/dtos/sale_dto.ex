defmodule VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO do
  alias VeiculeStorage.Domain.Entities.Sale

  defstruct [:id, :inventory_id, :payment_id, :status]

  @type t :: %__MODULE__{
          id: String.t(),
          inventory_id: String.t(),
          payment_id: String.t(),
          status: String.t()
        }

  def to_domain(%__MODULE__{} = dto) do
    Sale.new(%{
      id: dto.id,
      inventory_id: dto.inventory_id,
      payment_id: dto.payment_id,
      status: dto.status
    })
  end

  def from_map(map) when is_map(map) do
    map_with_atoms =
      map
      |> Enum.map(fn {key, value} ->
        {String.to_existing_atom(key), value}
      end)
      |> Map.new()

    dto = %__MODULE__{
      id: map_with_atoms |> Map.get(:id),
      inventory_id: map_with_atoms |> Map.get(:inventory_id),
      payment_id: map_with_atoms |> Map.get(:payment_id),
      status: map_with_atoms |> Map.get(:status)
    }

    {:ok, dto}
  end
end
