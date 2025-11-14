defmodule VeiculeStorage.Domain.Entities.SaleTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Sale

  describe "new/1" do
    test "creates a sale with valid attributes" do
      # Arrange
      attrs = %{
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }

      # Act
      result = Sale.new(attrs)

      # Assert
      assert {:ok, %Sale{
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }} = result
    end

    test "creates a sale with id when provided" do
      # Arrange
      attrs = %{
        id: "sale-uuid-789",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "PAYMENT_COMPLETED"
      }

      # Act
      result = Sale.new(attrs)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-789",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "PAYMENT_COMPLETED"
      }} = result
    end

    test "creates a sale with only inventory_id" do
      # Arrange
      attrs = %{
        inventory_id: "inventory-uuid-123"
      }

      # Act
      result = Sale.new(attrs)

      # Assert
      assert {:ok, %Sale{
        inventory_id: "inventory-uuid-123",
        payment_id: nil,
        status: nil
      }} = result
    end
  end
end
