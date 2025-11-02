defmodule VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO do
  alias VeiculeStorage.Domain.Entities.Veicule

  defstruct [:id, :brand, :model, :year, :color]

  @type t :: %__MODULE__{
          id: String.t(),
          brand: String.t(),
          model: String.t(),
          year: integer(),
          color: String.t()
        }

  def to_domain(%__MODULE__{} = dto) do
    Veicule.new(%{
      id: dto.id,
      brand: dto.brand,
      model: dto.model,
      year: dto.year,
      color: dto.color
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
      brand: map_with_atoms |> Map.get(:brand) |> handle_value(),
      model: map_with_atoms |> Map.get(:model) |> handle_value(),
      year: map_with_atoms |> Map.get(:year) |> handle_value_to_integer(),
      color: map_with_atoms |> Map.get(:color) |> handle_value()
    }

    {:ok, dto}
  end

  defp handle_value(value) when is_binary(value), do: value
  defp handle_value_to_integer(value) when is_binary(value), do: String.to_integer(value)
  defp handle_value_to_integer(value) when is_integer(value), do: value
  defp handle_value(_), do: nil
end
