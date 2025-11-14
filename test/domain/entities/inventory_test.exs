defmodule VeiculeStorage.Domain.Entities.InventoryTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Inventory

  describe "new/1" do
    test "creates an inventory with valid attributes" do
      # Arrange
      attrs = %{
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      # Act
      result = Inventory.new(attrs)

      # Assert
      assert {:ok, %Inventory{
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }} = result
    end

    test "creates an inventory with id when provided" do
      # Arrange
      attrs = %{
        id: "inventory-uuid-456",
        veicule_id: "veicule-uuid-123",
        price: 95000.00
      }

      # Act
      result = Inventory.new(attrs)

      # Assert
      assert {:ok, %Inventory{
        id: "inventory-uuid-456",
        veicule_id: "veicule-uuid-123",
        price: 95000.00
      }} = result
    end

    test "creates an inventory with veicule when provided" do
      # Arrange
      attrs = %{
        veicule_id: "veicule-uuid-123",
        price: 75000.00,
        veicule: %{brand: "Toyota", model: "Corolla"}
      }

      # Act
      result = Inventory.new(attrs)

      # Assert
      assert {:ok, %Inventory{
        veicule_id: "veicule-uuid-123",
        price: 75000.00,
        veicule: %{brand: "Toyota", model: "Corolla"}
      }} = result
    end
  end
end
