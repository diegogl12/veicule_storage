defmodule VeiculeStorage.InterfaceAdapters.Controllers.SaleInternalControllerTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Payment
  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.InterfaceAdapters.Controllers.SaleInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO
  alias VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO
  alias VeiculeStorage.InterfaceAdapters.Gateways.Clients.Mercadopago
  alias VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.PaymentRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository
  alias VeiculeStorage.UseCases.SalePaymentUpdate
  alias VeiculeStorage.UseCases.Sell

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "sell/1" do
    test "successfully processes a sale" do
      # Arrange
      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      sale = %Sale{
        inventory_id: "inventory-uuid-123"
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      completed_sale = %Sale{
        id: "sale-uuid-456",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      stub(SellInputDTO, :to_sale, fn ^dto -> {:ok, sale} end)
      stub(SellInputDTO, :to_payment, fn ^dto -> {:ok, payment} end)
      stub(Sell, :run, fn ^sale, ^payment, SaleRepository, InventoryRepository, PaymentRepository, Mercadopago ->
        {:ok, completed_sale}
      end)

      # Act
      result = SaleInternalController.sell(dto)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-456",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }} = result
    end

    test "returns error when sale conversion fails" do
      # Arrange
      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      stub(SellInputDTO, :to_sale, fn ^dto -> {:error, :invalid_sale} end)

      # Act
      result = SaleInternalController.sell(dto)

      # Assert
      assert {:error, :invalid_sale} = result
    end

    test "returns error when payment conversion fails" do
      # Arrange
      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      sale = %Sale{
        inventory_id: "inventory-uuid-123"
      }

      stub(SellInputDTO, :to_sale, fn ^dto -> {:ok, sale} end)
      stub(SellInputDTO, :to_payment, fn ^dto -> {:error, :invalid_payment} end)

      # Act
      result = SaleInternalController.sell(dto)

      # Assert
      assert {:error, :invalid_payment} = result
    end

    test "returns error when use case fails" do
      # Arrange
      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      sale = %Sale{
        inventory_id: "inventory-uuid-123"
      }

      payment = %Payment{
        payment_method: "PIX",
        payment_value: 85000.00
      }

      stub(SellInputDTO, :to_sale, fn ^dto -> {:ok, sale} end)
      stub(SellInputDTO, :to_payment, fn ^dto -> {:ok, payment} end)
      stub(Sell, :run, fn ^sale, ^payment, SaleRepository, InventoryRepository, PaymentRepository, Mercadopago ->
        {:error, :inventory_not_found}
      end)

      # Act
      result = SaleInternalController.sell(dto)

      # Assert
      assert {:error, :inventory_not_found} = result
    end
  end

  describe "get_sales/0" do
    test "successfully gets all sales" do
      # Arrange
      sales = [
        %Sale{id: "sale-1", inventory_id: "inv-1", payment_id: "pay-1", status: "IN_PROGRESS"},
        %Sale{id: "sale-2", inventory_id: "inv-2", payment_id: "pay-2", status: "PAYMENT_COMPLETED"}
      ]

      stub(SaleRepository, :get_all, fn -> {:ok, sales} end)

      # Act
      result = SaleInternalController.get_sales()

      # Assert
      assert {:ok, ^sales} = result
    end

    test "returns error when repository fails" do
      # Arrange
      stub(SaleRepository, :get_all, fn -> {:error, :database_error} end)

      # Act
      result = SaleInternalController.get_sales()

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "sale_status_update/1" do
    test "successfully updates sale status" do
      # Arrange
      dto = %SaleDTO{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_VALIDATED"
      }

      sale_domain = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_VALIDATED"
      }

      updated_sale = %Sale{
        id: "sale-uuid-123",
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_COMPLETED"
      }

      stub(SaleDTO, :to_domain, fn ^dto -> {:ok, sale_domain} end)
      stub(SalePaymentUpdate, :execute, fn ^sale_domain, SaleRepository, PaymentRepository ->
        {:ok, updated_sale}
      end)

      # Act
      result = SaleInternalController.sale_status_update(dto)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-123",
        status: "PAYMENT_COMPLETED"
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      dto = %SaleDTO{
        id: "sale-uuid-123",
        status: "INVALID_STATUS"
      }

      stub(SaleDTO, :to_domain, fn ^dto -> {:error, :invalid_data} end)

      # Act
      result = SaleInternalController.sale_status_update(dto)

      # Assert
      assert {:error, :invalid_data} = result
    end

    test "returns error when use case fails" do
      # Arrange
      dto = %SaleDTO{
        id: "sale-uuid-123",
        status: "PAYMENT_VALIDATED"
      }

      sale_domain = %Sale{
        id: "sale-uuid-123",
        status: "PAYMENT_VALIDATED"
      }

      stub(SaleDTO, :to_domain, fn ^dto -> {:ok, sale_domain} end)
      stub(SalePaymentUpdate, :execute, fn ^sale_domain, SaleRepository, PaymentRepository ->
        {:error, :sale_not_found}
      end)

      # Act
      result = SaleInternalController.sale_status_update(dto)

      # Assert
      assert {:error, :sale_not_found} = result
    end
  end
end
