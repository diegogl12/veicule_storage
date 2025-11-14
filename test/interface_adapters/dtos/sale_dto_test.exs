defmodule VeiculeStorage.InterfaceAdapters.DTOs.SaleDTOTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO

  describe "to_domain/1" do
    test "converts DTO to domain entity successfully" do
      # Arrange
      dto = %SaleDTO{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      # Act
      result = SaleDTO.to_domain(dto)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }} = result
    end

    test "converts DTO without id to domain entity" do
      # Arrange
      dto = %SaleDTO{
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "PAYMENT_COMPLETED"
      }

      # Act
      result = SaleDTO.to_domain(dto)

      # Assert
      assert {:ok, %Sale{
        id: nil,
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "PAYMENT_COMPLETED"
      }} = result
    end
  end

  describe "from_map/1" do
    test "converts map with string keys to DTO successfully" do
      # Arrange
      map = %{
        "id" => "sale-uuid-123",
        "inventory_id" => "inventory-uuid-456",
        "payment_id" => "payment-uuid-789",
        "status" => "IN_PROGRESS"
      }

      # Act
      result = SaleDTO.from_map(map)

      # Assert
      assert {:ok, %SaleDTO{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }} = result
    end

    test "converts map without id to DTO successfully" do
      # Arrange
      map = %{
        "inventory_id" => "inventory-uuid-123",
        "payment_id" => "payment-uuid-456",
        "status" => "PAYMENT_CANCELLED"
      }

      # Act
      result = SaleDTO.from_map(map)

      # Assert
      assert {:ok, %SaleDTO{
        id: nil,
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "PAYMENT_CANCELLED"
      }} = result
    end
  end
end
