defmodule VeiculeStorage.Infra.Web.Controllers.SaleControllerTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.Infra.Web.Controllers.SaleController
  alias VeiculeStorage.InterfaceAdapters.Controllers.SaleInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.SaleDTO
  alias VeiculeStorage.InterfaceAdapters.DTOs.SellInputDTO

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "sell/1" do
    test "successfully processes a sale" do
      # Arrange
      params = %{
        "inventory_id" => "inventory-uuid-123",
        "payment_method" => "PIX",
        "payment_value" => "85000.00"
      }

      dto = %SellInputDTO{
        inventory_id: "inventory-uuid-123",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      completed_sale = %Sale{
        id: "sale-uuid-456",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      stub(SellInputDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(SaleInternalController, :sell, fn ^dto -> {:ok, completed_sale} end)

      # Act
      result = SaleController.sell(params)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-456",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      params = %{"invalid" => "data"}

      stub(SellInputDTO, :from_map, fn ^params -> {:error, :invalid_params} end)

      # Act
      result = SaleController.sell(params)

      # Assert
      assert {:error, :invalid_params} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      params = %{
        "inventory_id" => "non-existent-inventory",
        "payment_method" => "PIX",
        "payment_value" => "85000.00"
      }

      dto = %SellInputDTO{
        inventory_id: "non-existent-inventory",
        payment_method: "PIX",
        payment_value: 85000.00
      }

      stub(SellInputDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(SaleInternalController, :sell, fn ^dto -> {:error, :inventory_not_found} end)

      # Act
      result = SaleController.sell(params)

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

      stub(SaleInternalController, :get_sales, fn -> {:ok, sales} end)

      # Act
      result = SaleController.get_sales()

      # Assert
      assert {:ok, ^sales} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      stub(SaleInternalController, :get_sales, fn -> {:error, :database_error} end)

      # Act
      result = SaleController.get_sales()

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "sale_status_update/1" do
    test "successfully updates sale status" do
      # Arrange
      params = %{
        "id" => "sale-uuid-123",
        "inventory_id" => "inventory-uuid-456",
        "payment_id" => "payment-uuid-789",
        "status" => "PAYMENT_VALIDATED"
      }

      dto = %SaleDTO{
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

      stub(SaleDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(SaleInternalController, :sale_status_update, fn ^dto -> {:ok, updated_sale} end)

      # Act
      result = SaleController.sale_status_update(params)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-123",
        status: "PAYMENT_COMPLETED"
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      params = %{"invalid" => "data"}

      stub(SaleDTO, :from_map, fn ^params -> {:error, :invalid_params} end)

      # Act
      result = SaleController.sale_status_update(params)

      # Assert
      assert {:error, :invalid_params} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      params = %{
        "id" => "non-existent-sale",
        "status" => "PAYMENT_VALIDATED"
      }

      dto = %SaleDTO{
        id: "non-existent-sale",
        status: "PAYMENT_VALIDATED"
      }

      stub(SaleDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(SaleInternalController, :sale_status_update, fn ^dto -> {:error, :not_found} end)

      # Act
      result = SaleController.sale_status_update(params)

      # Assert
      assert {:error, :not_found} = result
    end
  end
end
