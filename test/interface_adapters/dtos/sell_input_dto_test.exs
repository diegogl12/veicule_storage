defmodule VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTOTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO

  describe "from_map/1" do
    test "converts map with string keys to DTO successfully" do
      # Arrange
      map = %{
        "inventory_id" => "inventory-uuid-123",
        "payment_method" => "PIX",
        "payment_value" => "85000.00"
      }

      # Act
      result = SellInputDTO.from_map(map)

      # Assert
      assert {:ok, %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }} = result
    end

    test "converts map with float payment_value to DTO successfully" do
      # Arrange
      map = %{
        "inventory_id" => "inventory-uuid-456",
        "payment_method" => "CREDIT_CARD",
        "payment_value" => 95000.00
      }

      # Act
      result = SellInputDTO.from_map(map)

      # Assert
      assert {:ok, %SellInputDTO{
        inventory_id: "inventory-uuid-456",
        payment_method: "CREDIT_CARD",
        payment_value: 95000.00
      }} = result
    end

    test "converts map with integer payment_value to DTO successfully" do
      # Arrange
      map = %{
        "inventory_id" => "inventory-uuid-789",
        "payment_method" => "PIX",
        "payment_value" => 100000
      }

      # Act
      result = SellInputDTO.from_map(map)

      # Assert
      assert {:ok, %SellInputDTO{
        inventory_id: "inventory-uuid-789",
        payment_method: "PIX",
        payment_value: 100000.0
      }} = result
    end
  end

  describe "to_sale/1" do
    test "converts DTO to Sale entity successfully" do
      # Arrange
      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      # Act
      result = SellInputDTO.to_sale(dto)

      # Assert
      assert {:ok, %Sale{
        inventory_id: "inventory-uuid-123",
        payment_id: nil,
        status: nil
      }} = result
    end
  end

  describe "to_payment/1" do
    test "converts DTO to Payment entity successfully" do
      # Arrange
      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      # Act
      result = SellInputDTO.to_payment(dto)

      # Assert
      assert {:ok, %Payment{
        payment_method: "PIX",
        payment_value: 85000.00,
        status: nil,
        payment_date: nil
      }} = result
    end
  end
end
