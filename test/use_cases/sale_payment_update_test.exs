defmodule VeiculeStorage.UseCases.SalePaymentUpdateTest do
  use ExUnit.Case, async: true
  import Mox

  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.UseCases.SalePaymentUpdate

  setup :verify_on_exit!

  describe "execute/3" do
    test "successfully updates sale and payment to PAYMENT_COMPLETED" do
      # Arrange
      sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_VALIDATED"
      }

      current_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      current_payment = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING"
      }

      updated_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_COMPLETED"
      }

      updated_payment = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "COMPLETED"
      }

      # Expectations
      expect(SaleRepositoryMock, :get, fn "sale-uuid-123" ->
        {:ok, current_sale}
      end)

      expect(PaymentRepositoryMock, :get, fn "payment-uuid-789" ->
        {:ok, current_payment}
      end)

      expect(SaleRepositoryMock, :update, fn %Sale{status: "PAYMENT_COMPLETED"} ->
        {:ok, updated_sale}
      end)

      expect(PaymentRepositoryMock, :update, fn %Payment{status: "COMPLETED"} ->
        {:ok, updated_payment}
      end)

      # Act
      result = SalePaymentUpdate.execute(sale, SaleRepositoryMock, PaymentRepositoryMock)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-123",
        status: "PAYMENT_COMPLETED"
      }} = result
    end

    test "successfully updates sale and payment to PAYMENT_CANCELLED" do
      # Arrange
      sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_CANCELLED"
      }

      current_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      current_payment = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING"
      }

      updated_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_CANCELLED"
      }

      updated_payment = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "CANCELLED"
      }

      # Expectations
      expect(SaleRepositoryMock, :get, fn "sale-uuid-123" ->
        {:ok, current_sale}
      end)

      expect(PaymentRepositoryMock, :get, fn "payment-uuid-789" ->
        {:ok, current_payment}
      end)

      expect(SaleRepositoryMock, :update, fn %Sale{status: "PAYMENT_CANCELLED"} ->
        {:ok, updated_sale}
      end)

      expect(PaymentRepositoryMock, :update, fn %Payment{status: "CANCELLED"} ->
        {:ok, updated_payment}
      end)

      # Act
      result = SalePaymentUpdate.execute(sale, SaleRepositoryMock, PaymentRepositoryMock)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-123",
        status: "PAYMENT_CANCELLED"
      }} = result
    end

    test "sets ERROR status for unknown sale status" do
      # Arrange
      sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "UNKNOWN_STATUS"
      }

      current_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      current_payment = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING"
      }

      updated_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "ERROR"
      }

      updated_payment = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "ERROR"
      }

      # Expectations
      expect(SaleRepositoryMock, :get, fn "sale-uuid-123" ->
        {:ok, current_sale}
      end)

      expect(PaymentRepositoryMock, :get, fn "payment-uuid-789" ->
        {:ok, current_payment}
      end)

      expect(SaleRepositoryMock, :update, fn %Sale{status: "ERROR"} ->
        {:ok, updated_sale}
      end)

      expect(PaymentRepositoryMock, :update, fn %Payment{status: "ERROR"} ->
        {:ok, updated_payment}
      end)

      # Act
      result = SalePaymentUpdate.execute(sale, SaleRepositoryMock, PaymentRepositoryMock)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-123",
        status: "ERROR"
      }} = result
    end

    test "returns error when sale is not found" do
      # Arrange
      sale = %Sale{
        id: "non-existent-sale",
        status: "PAYMENT_VALIDATED"
      }

      expect(SaleRepositoryMock, :get, fn "non-existent-sale" ->
        {:error, :not_found}
      end)

      # Act
      result = SalePaymentUpdate.execute(sale, SaleRepositoryMock, PaymentRepositoryMock)

      # Assert
      assert {:error, :not_found} = result
    end

    test "returns error when payment is not found" do
      # Arrange
      sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "non-existent-payment",
        status: "PAYMENT_VALIDATED"
      }

      current_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "non-existent-payment",
        status: "IN_PROGRESS"
      }

      expect(SaleRepositoryMock, :get, fn "sale-uuid-123" ->
        {:ok, current_sale}
      end)

      expect(PaymentRepositoryMock, :get, fn "non-existent-payment" ->
        {:error, :not_found}
      end)

      # Act
      result = SalePaymentUpdate.execute(sale, SaleRepositoryMock, PaymentRepositoryMock)

      # Assert
      assert {:error, :not_found} = result
    end
  end
end
