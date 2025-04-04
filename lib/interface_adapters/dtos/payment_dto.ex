defmodule VeiculeStorage.InterfaceAdapters.DTOs.CheckoutDTO do
  alias VeiculeStorage.Domain.Entities.Payment

  defstruct [:id, :payment_method, :payment_value, :status, :payment_date]

  @type t :: %__MODULE__{
          id: String.t(),
          payment_method: String.t(),
          payment_value: float(),
          status: String.t(),
          payment_date: NaiveDateTime.t()
        }

  def to_domain(%__MODULE__{} = dto) do
    Payment.new(%{
      id: dto.id,
      payment_method: dto.payment_method,
      payment_value: dto.payment_value,
      status: dto.status,
      payment_date: NaiveDateTime.truncate(dto.payment_date, :second)
    })
  end

  def from_json(json) do
    with {:ok, data} <- Jason.decode(json),
         {:ok, dto} <- from_map(data) do
      {:ok, dto}
    end
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
      payment_value: Map.get(map_with_atoms, :payment_value) |> handle_value(),
      status: Map.get(map_with_atoms, :status) |> handle_value(),
      payment_date: Map.get(map_with_atoms, :payment_date) |> handle_value()
    }

    {:ok, dto}
  rescue
    ArgumentError -> {:error, "Invalid payment data - unknown fields"}
    _ -> {:error, "Invalid payment data"}
  end

  defp handle_value(value) when is_binary(value), do: value
  defp handle_value(value) when is_integer(value), do: Integer.to_string(value)
  defp handle_value(_), do: nil
end
