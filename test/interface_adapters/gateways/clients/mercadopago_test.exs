defmodule VeiculeStorage.InterfaceAdapters.Gateways.Clients.MercadopagoTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.InterfaceAdapters.Gateways.Clients.Mercadopago

  describe "perform_payment/1" do
    test "successfully processes a payment" do
      # Arrange
      payment = %Payment{
        id: "payment-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "INITIAL"
      }

      # Act
      result = Mercadopago.perform_payment(payment)

      # Assert
      assert {:ok, %Payment{
        id: "payment-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "INITIAL"
      }} = result
    end

    test "successfully processes a payment with credit card" do
      # Arrange
      payment = %Payment{
        id: "payment-uuid-456",
        payment_method: "CREDIT_CARD",
        payment_value: 95000.00,
        status: "INITIAL"
      }

      # Act
      result = Mercadopago.perform_payment(payment)

      # Assert
      assert {:ok, %Payment{
        id: "payment-uuid-456",
        payment_method: "CREDIT_CARD",
        payment_value: 95000.00,
        status: "INITIAL"
      }} = result
    end

    test "successfully processes a payment without id" do
      # Arrange
      payment = %Payment{
        payment_method: "PIX",
        payment_value: 75000.00,
        status: "INITIAL"
      }

      # Act
      result = Mercadopago.perform_payment(payment)

      # Assert
      assert {:ok, %Payment{
        id: nil,
        payment_method: "PIX",
        payment_value: 75000.00,
        status: "INITIAL"
      }} = result
    end
  end
end
