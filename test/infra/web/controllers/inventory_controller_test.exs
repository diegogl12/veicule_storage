defmodule VeiculeStorage.Infra.Web.Controllers.InventoryControllerTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.Infra.Web.Controllers.InventoryController
  alias VeiculeStorage.InterfaceAdapters.Controllers.InventoryInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "create_inventory/1" do
    test "successfully creates an inventory" do
      # Arrange
      params = %{
        "veicule_id" => "veicule-uuid-123",
        "price" => "85000.00"
      }

      dto = %InventoryDTO{
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      created_inventory = %Inventory{
        id: "new-inventory-uuid",
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      stub(InventoryDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(InventoryInternalController, :create, fn ^dto -> {:ok, created_inventory} end)

      # Act
      result = InventoryController.create_inventory(params)

      # Assert
      assert {:ok, %Inventory{
        id: "new-inventory-uuid",
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      params = %{"invalid" => "data"}

      stub(InventoryDTO, :from_map, fn ^params -> {:error, :invalid_params} end)

      # Act
      result = InventoryController.create_inventory(params)

      # Assert
      assert {:error, :invalid_params} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      params = %{
        "veicule_id" => "non-existent-veicule",
        "price" => "85000.00"
      }

      dto = %InventoryDTO{
        veicule_id: "non-existent-veicule",
        price: 85000.00
      }

      stub(InventoryDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(InventoryInternalController, :create, fn ^dto -> {:error, :veicule_not_found} end)

      # Act
      result = InventoryController.create_inventory(params)

      # Assert
      assert {:error, :veicule_not_found} = result
    end
  end

  describe "update_inventory/2" do
    test "successfully updates an inventory" do
      # Arrange
      params = %{
        "veicule_id" => "veicule-uuid-456",
        "price" => "95000.00"
      }

      id = "inventory-uuid-123"

      dto = %InventoryDTO{
        id: id,
        veicule_id: "veicule-uuid-456",
        price: 95000.00
      }

      updated_inventory = %Inventory{
        id: id,
        veicule_id: "veicule-uuid-456",
        price: 95000.00
      }

      stub(InventoryDTO, :from_map, fn _map -> {:ok, dto} end)
      stub(InventoryInternalController, :update, fn ^dto -> {:ok, updated_inventory} end)

      # Act
      result = InventoryController.update_inventory(params, id)

      # Assert
      assert {:ok, %Inventory{
        id: ^id,
        price: 95000.00
      }} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      params = %{
        "veicule_id" => "veicule-uuid-456",
        "price" => "95000.00"
      }

      id = "non-existent-id"

      dto = %InventoryDTO{
        id: id,
        veicule_id: "veicule-uuid-456",
        price: 95000.00
      }

      stub(InventoryDTO, :from_map, fn _map -> {:ok, dto} end)
      stub(InventoryInternalController, :update, fn ^dto -> {:error, :not_found} end)

      # Act
      result = InventoryController.update_inventory(params, id)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "get_all_inventories/0" do
    test "successfully gets all inventories" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 85000.00},
        %Inventory{id: "inv-2", veicule_id: "v-2", price: 95000.00}
      ]

      stub(InventoryInternalController, :get_all, fn -> {:ok, inventories} end)

      # Act
      result = InventoryController.get_all_inventories()

      # Assert
      assert {:ok, ^inventories} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      stub(InventoryInternalController, :get_all, fn -> {:error, :database_error} end)

      # Act
      result = InventoryController.get_all_inventories()

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "get_all_to_sell/0" do
    test "successfully gets inventories to sell" do
      # Arrange
      inventories_dto = [
        %InventoryDTO{id: "inv-1", veicule_id: "v-1", price: 85000.00}
      ]

      stub(InventoryInternalController, :get_all_to_sell, fn -> {:ok, inventories_dto} end)

      # Act
      result = InventoryController.get_all_to_sell()

      # Assert
      assert {:ok, ^inventories_dto} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      stub(InventoryInternalController, :get_all_to_sell, fn -> {:error, :use_case_error} end)

      # Act
      result = InventoryController.get_all_to_sell()

      # Assert
      assert {:error, :use_case_error} = result
    end
  end

  describe "get_all_sold/0" do
    test "successfully gets sold inventories" do
      # Arrange
      inventories_dto = [
        %InventoryDTO{id: "inv-1", veicule_id: "v-1", price: 85000.00}
      ]

      stub(InventoryInternalController, :get_all_sold, fn -> {:ok, inventories_dto} end)

      # Act
      result = InventoryController.get_all_sold()

      # Assert
      assert {:ok, ^inventories_dto} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      stub(InventoryInternalController, :get_all_sold, fn -> {:error, :use_case_error} end)

      # Act
      result = InventoryController.get_all_sold()

      # Assert
      assert {:error, :use_case_error} = result
    end
  end
end
