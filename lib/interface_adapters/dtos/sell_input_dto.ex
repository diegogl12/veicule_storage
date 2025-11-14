defmodule VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO do
  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Domain.Entities.Sale

  defstruct [:inventory_id, :payment_method, :payment_value]

  @type t :: %__MODULE__{
          inventory_id: String.t(),
          payment_method: String.t(),
          payment_value: float()
        }

  def from_map(map) when is_map(map) do
    map_with_atoms =
      map
      |> Enum.map(fn {key, value} ->
        {String.to_existing_atom(key), value}
      end)
      |> Map.new()

    dto = %__MODULE__{
      inventory_id: map_with_atoms |> Map.get(:inventory_id) |> handle_value(),
      payment_method: map_with_atoms |> Map.get(:payment_method) |> handle_value(),
      payment_value: map_with_atoms |> Map.get(:payment_value) |> handle_value_to_float()
    }

    {:ok, dto}
  end

  def to_sale(%__MODULE__{} = dto) do
    sale = %Sale{
      inventory_id: dto.inventory_id,
    }

    {:ok, sale}
  end

  def to_payment(%__MODULE__{} = dto) do
    payment = %Payment{
      payment_method: dto.payment_method,
      payment_value: dto.payment_value
    }

    {:ok, payment}
  end

  defp handle_value(value) when is_binary(value), do: value
  defp handle_value(_), do: nil

  defp handle_value_to_float(value) when is_binary(value), do: String.to_float(value)
  defp handle_value_to_float(value) when is_integer(value), do: value * 1.0
  defp handle_value_to_float(value) when is_float(value), do: value
end
