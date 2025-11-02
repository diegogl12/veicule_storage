defmodule VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO do
  alias VeiculeStorage.Domain.Entities.Inventory

  defstruct [:id, :veicule_id, :price]

  @type t :: %__MODULE__{
          id: String.t(),
          veicule_id: String.t(),
          price: float()
        }

  def to_domain(%__MODULE__{} = dto) do
    Inventory.new(%{
      id: dto.id,
      veicule_id: dto.veicule_id,
      price: dto.price
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
      id: map_with_atoms |> Map.get(:id) |> handle_value(),
      veicule_id: map_with_atoms |> Map.get(:veicule_id) |> handle_value(),
      price: map_with_atoms |> Map.get(:price) |> handle_value_to_float()
    }

    {:ok, dto}
  end

  defp handle_value(value) when is_binary(value), do: value
  defp handle_value_to_float(value) when is_binary(value), do: String.to_float(value)
  defp handle_value_to_float(value) when is_integer(value), do: Integer.to_float(value)
  defp handle_value_to_float(value) when is_float(value), do: value
  defp handle_value(_), do: nil
end
