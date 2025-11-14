defmodule VeiculeStorage.Domain.Entities.PaymentTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Payment

  describe "new/1" do
    test "creates a payment with valid attributes" do
      # Arrange
      attrs = %{
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING"
      }

      # Act
      result = Payment.new(attrs)

      # Assert
      assert {:ok, %Payment{
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING"
      }} = result
    end

    test "creates a payment with id when provided" do
      # Arrange
      attrs = %{
        id: "payment-uuid-123",
        payment_method: "CREDIT_CARD",
        payment_value: 95000.00,
        status: "COMPLETED"
      }

      # Act
      result = Payment.new(attrs)

      # Assert
      assert {:ok, %Payment{
        id: "payment-uuid-123",
        payment_method: "CREDIT_CARD",
        payment_value: 95000.00,
        status: "COMPLETED"
      }} = result
    end

    test "creates a payment with payment_date when provided" do
      # Arrange
      payment_date = ~N[2025-11-14 10:00:00]
      attrs = %{
        payment_method: "PIX",
        payment_value: 75000.00,
        status: "INITIAL",
        payment_date: payment_date
      }

      # Act
      result = Payment.new(attrs)

      # Assert
      assert {:ok, %Payment{
        payment_method: "PIX",
        payment_value: 75000.00,
        status: "INITIAL",
        payment_date: ^payment_date
      }} = result
    end
  end
end
