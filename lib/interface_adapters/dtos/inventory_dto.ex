defmodule VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO do
  @derive {Jason.Encoder, only: [:id, :veicule_id, :price, :veicule]}
  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO

  defstruct [:id, :veicule_id, :price, :veicule]

  @type t :: %__MODULE__{
          id: String.t(),
          veicule_id: String.t(),
          price: float(),
          veicule: VeiculeDTO.t() | nil
        }

  def to_domain(%__MODULE__{} = dto) do
    Inventory.new(%{
      id: dto.id,
      veicule_id: dto.veicule_id,
      price: dto.price
    })
  end

  def from_domain(%Inventory{} = domain) do
    %__MODULE__{
      id: domain.id,
      veicule_id: domain.veicule_id,
      price: domain.price,
      veicule: VeiculeDTO.from_domain(domain.veicule)
    }
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
      price: map_with_atoms |> Map.get(:price) |> handle_value_to_float(),
      veicule: map_with_atoms |> Map.get(:veicule) |> VeiculeDTO.from_map()
    }

    {:ok, dto}
  end

  defp handle_value(value) when is_binary(value), do: value
  defp handle_value(_), do: nil

  defp handle_value_to_float(value) when is_binary(value), do: String.to_float(value)
  defp handle_value_to_float(value) when is_integer(value), do: value * 1.0
  defp handle_value_to_float(value) when is_float(value), do: value
end
