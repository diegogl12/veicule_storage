defmodule VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTOTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO

  describe "to_domain/1" do
    test "converts DTO to domain entity successfully" do
      # Arrange
      dto = %InventoryDTO{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      # Act
      result = InventoryDTO.to_domain(dto)

      # Assert
      assert {:ok, %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }} = result
    end

    test "converts DTO without id to domain entity" do
      # Arrange
      dto = %InventoryDTO{
        veicule_id: "veicule-uuid-789",
        price: 95000.00
      }

      # Act
      result = InventoryDTO.to_domain(dto)

      # Assert
      assert {:ok, %Inventory{
        id: nil,
        veicule_id: "veicule-uuid-789",
        price: 95000.00
      }} = result
    end
  end

  describe "from_domain/1" do
    test "converts domain entity to DTO successfully" do
      # Arrange
      veicule = %Veicule{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      inventory = %Inventory{
        id: "inventory-uuid-456",
        veicule_id: "veicule-uuid-123",
        price: 85000.00,
        veicule: veicule
      }

      # Act
      result = InventoryDTO.from_domain(inventory)

      # Assert
      assert %InventoryDTO{
        id: "inventory-uuid-456",
        veicule_id: "veicule-uuid-123",
        price: 85000.00,
        veicule: %VeiculeDTO{
          id: "veicule-uuid-123",
          brand: "Toyota",
          model: "Corolla",
          year: 2023,
          color: "Prata"
        }
      } = result
    end

    test "converts domain entity with nil veicule" do
      # Arrange
      inventory = %Inventory{
        id: "inventory-uuid-789",
        veicule_id: "veicule-uuid-123",
        price: 75000.00,
        veicule: nil
      }

      # Act
      result = InventoryDTO.from_domain(inventory)

      # Assert
      assert %InventoryDTO{
        id: "inventory-uuid-789",
        veicule_id: "veicule-uuid-123",
        price: 75000.00,
        veicule: nil
      } = result
    end
  end

  describe "from_map/1" do
    test "converts map with string keys to DTO successfully" do
      # Arrange
      map = %{
        "id" => "inventory-uuid-123",
        "veicule_id" => "veicule-uuid-456",
        "price" => "85000.00"
      }

      # Act
      result = InventoryDTO.from_map(map)

      # Assert
      assert {:ok, %InventoryDTO{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }} = result
    end

    test "converts map with float price to DTO successfully" do
      # Arrange
      map = %{
        "veicule_id" => "veicule-uuid-789",
        "price" => 95000.00
      }

      # Act
      result = InventoryDTO.from_map(map)

      # Assert
      assert {:ok, %InventoryDTO{
        veicule_id: "veicule-uuid-789",
        price: 95000.00
      }} = result
    end

    test "converts map with integer price to DTO successfully" do
      # Arrange
      map = %{
        "veicule_id" => "veicule-uuid-789",
        "price" => 100000
      }

      # Act
      result = InventoryDTO.from_map(map)

      # Assert
      assert {:ok, %InventoryDTO{
        veicule_id: "veicule-uuid-789",
        price: 100000.0
      }} = result
    end
  end
end
