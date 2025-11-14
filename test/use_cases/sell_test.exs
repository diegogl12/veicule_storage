defmodule VeiculeStorage.UseCases.SellTest do
  use ExUnit.Case, async: true
  import Mox

  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.UseCases.Sell

  setup :verify_on_exit!

  describe "run/6" do
    test "successfully processes a complete sale" do
      # Arrange
      sale = %Sale{
        inventory_id: "inventory-uuid-123"
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      inventory = %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      payment_with_id = %Payment{
        id: "payment-uuid-789",
        payment_method: "PIX",
        payment_value: 85000.00,
        status: "PENDING"
      }

      final_sale = %Sale{
        id: "sale-uuid-999",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      # Expectations
      expect(InventoryRepositoryMock, :get, fn "inventory-uuid-123" ->
        {:ok, inventory}
      end)

      expect(PaymentRepositoryMock, :create, fn %Payment{status: "INITIAL"} ->
        {:ok, %{payment | id: "payment-uuid-789", status: "INITIAL"}}
      end)

      expect(PaymentGatewayMock, :perform_payment, fn %Payment{id: "payment-uuid-789"} ->
        {:ok, %{payment | id: "payment-uuid-789", status: "INITIAL"}}
      end)

      expect(PaymentRepositoryMock, :update, fn %Payment{status: "PENDING"} ->
        {:ok, payment_with_id}
      end)

      expect(SaleRepositoryMock, :create, fn %Sale{
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      } ->
        {:ok, final_sale}
      end)

      # Act
      result = Sell.run(
        sale,
        payment,
        SaleRepositoryMock,
        InventoryRepositoryMock,
        PaymentRepositoryMock,
        PaymentGatewayMock
      )

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-999",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }} = result
    end

    test "returns error when inventory is not found" do
      # Arrange
      sale = %Sale{
        inventory_id: "non-existent-inventory"
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      expect(InventoryRepositoryMock, :get, fn "non-existent-inventory" ->
        {:error, :not_found}
      end)

      # Act
      result = Sell.run(
        sale,
        payment,
        SaleRepositoryMock,
        InventoryRepositoryMock,
        PaymentRepositoryMock,
        PaymentGatewayMock
      )

      # Assert
      assert {:error, :not_found} = result
    end

    test "returns error when payment creation fails" do
      # Arrange
      sale = %Sale{
        inventory_id: "inventory-uuid-123"
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      inventory = %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      expect(InventoryRepositoryMock, :get, fn "inventory-uuid-123" ->
        {:ok, inventory}
      end)

      expect(PaymentRepositoryMock, :create, fn %Payment{status: "INITIAL"} ->
        {:error, :payment_creation_failed}
      end)

      # Act
      result = Sell.run(
        sale,
        payment,
        SaleRepositoryMock,
        InventoryRepositoryMock,
        PaymentRepositoryMock,
        PaymentGatewayMock
      )

      # Assert
      assert {:error, :payment_creation_failed} = result
    end

    test "returns error when payment gateway fails" do
      # Arrange
      sale = %Sale{
        inventory_id: "inventory-uuid-123"
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      inventory = %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      expect(InventoryRepositoryMock, :get, fn "inventory-uuid-123" ->
        {:ok, inventory}
      end)

      expect(PaymentRepositoryMock, :create, fn %Payment{status: "INITIAL"} ->
        {:ok, %{payment | id: "payment-uuid-789", status: "INITIAL"}}
      end)

      expect(PaymentGatewayMock, :perform_payment, fn %Payment{id: "payment-uuid-789"} ->
        {:error, :gateway_error}
      end)

      # Act
      result = Sell.run(
        sale,
        payment,
        SaleRepositoryMock,
        InventoryRepositoryMock,
        PaymentRepositoryMock,
        PaymentGatewayMock
      )

      # Assert
      assert {:error, :gateway_error} = result
    end

    test "returns error when sale has no inventory_id" do
      # Arrange
      sale = %Sale{
        inventory_id: nil
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      inventory = %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      expect(InventoryRepositoryMock, :get, fn nil ->
        {:ok, inventory}
      end)

      expect(PaymentRepositoryMock, :create, fn %Payment{status: "INITIAL"} ->
        {:ok, %{payment | id: "payment-uuid-789", status: "INITIAL"}}
      end)

      expect(PaymentGatewayMock, :perform_payment, fn %Payment{id: "payment-uuid-789"} ->
        {:ok, %{payment | id: "payment-uuid-789", status: "INITIAL"}}
      end)

      expect(PaymentRepositoryMock, :update, fn %Payment{status: "PENDING"} ->
        {:ok, %{payment | id: "payment-uuid-789", status: "PENDING"}}
      end)

      # Act
      result = Sell.run(
        sale,
        payment,
        SaleRepositoryMock,
        InventoryRepositoryMock,
        PaymentRepositoryMock,
        PaymentGatewayMock
      )

      # Assert
      assert {:error, "Inventory ID is required"} = result
    end
  end
end
