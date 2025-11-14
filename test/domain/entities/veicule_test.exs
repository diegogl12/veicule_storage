defmodule VeiculeStorage.Domain.Entities.VeiculeTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Veicule

  describe "new/1" do
    test "creates a veicule with valid attributes" do
      # Arrange
      attrs = %{
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      # Act
      result = Veicule.new(attrs)

      # Assert
      assert {:ok, %Veicule{
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }} = result
    end

    test "creates a veicule with id when provided" do
      # Arrange
      attrs = %{
        id: "uuid-123",
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      # Act
      result = Veicule.new(attrs)

      # Assert
      assert {:ok, %Veicule{
        id: "uuid-123",
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }} = result
    end
  end
end
