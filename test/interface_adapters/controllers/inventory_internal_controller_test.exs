defmodule VeiculeStorage.InterfaceAdapters.Controllers.InventoryInternalControllerTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.InterfaceAdapters.Controllers.InventoryInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.InventoryDTO
  alias VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository
  alias VeiculeStorage.UseCases.VeiculesSold
  alias VeiculeStorage.UseCases.VeiculesToSell

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "create/1" do
    test "successfully creates an inventory" do
      # Arrange
      dto = %InventoryDTO{
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      inventory_domain = %Inventory{
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      veicule = %Veicule{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      created_inventory = %Inventory{
        id: "new-inventory-uuid",
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      stub(InventoryDTO, :to_domain, fn ^dto -> {:ok, inventory_domain} end)
      stub(VeiculeRepository, :get, fn "veicule-uuid-123" -> {:ok, veicule} end)
      stub(InventoryRepository, :create, fn ^inventory_domain -> {:ok, created_inventory} end)

      # Act
      result = InventoryInternalController.create(dto)

      # Assert
      assert {:ok, %Inventory{
        id: "new-inventory-uuid",
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }} = result
    end

    test "returns error when veicule does not exist" do
      # Arrange
      dto = %InventoryDTO{
        veicule_id: "non-existent-veicule",
        price: 85000.00
      }

      inventory_domain = %Inventory{
        veicule_id: "non-existent-veicule",
        price: 85000.00
      }

      stub(InventoryDTO, :to_domain, fn ^dto -> {:ok, inventory_domain} end)
      stub(VeiculeRepository, :get, fn "non-existent-veicule" -> {:error, :not_found} end)

      # Act
      result = InventoryInternalController.create(dto)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "update/1" do
    test "successfully updates an inventory" do
      # Arrange
      dto = %InventoryDTO{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 95000.00
      }

      inventory_domain = %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 95000.00
      }

      veicule = %Veicule{
        id: "veicule-uuid-456",
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      updated_inventory = %Inventory{
        id: "inventory-uuid-123",
        veicule_id: "veicule-uuid-456",
        price: 95000.00
      }

      stub(InventoryDTO, :to_domain, fn ^dto -> {:ok, inventory_domain} end)
      stub(VeiculeRepository, :get, fn "veicule-uuid-456" -> {:ok, veicule} end)
      stub(InventoryRepository, :update, fn ^inventory_domain -> {:ok, updated_inventory} end)

      # Act
      result = InventoryInternalController.update(dto)

      # Assert
      assert {:ok, %Inventory{
        id: "inventory-uuid-123",
        price: 95000.00
      }} = result
    end
  end

  describe "get_all/0" do
    test "successfully gets all inventories" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 85000.00},
        %Inventory{id: "inv-2", veicule_id: "v-2", price: 95000.00}
      ]

      stub(InventoryRepository, :get_all, fn -> {:ok, inventories} end)

      # Act
      result = InventoryInternalController.get_all()

      # Assert
      assert {:ok, ^inventories} = result
    end

    test "returns error when repository fails" do
      # Arrange
      stub(InventoryRepository, :get_all, fn -> {:error, :database_error} end)

      # Act
      result = InventoryInternalController.get_all()

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "get_all_to_sell/0" do
    test "successfully gets all inventories to sell" do
      # Arrange
      inventories = [
        %Inventory{
          id: "inv-1",
          veicule_id: "v-1",
          price: 85000.00,
          veicule: %Veicule{id: "v-1", brand: "Toyota", model: "Corolla", year: 2023, color: "Prata"}
        }
      ]

      stub(VeiculesToSell, :execute, fn VeiculeRepository, InventoryRepository, SaleRepository ->
        {:ok, inventories}
      end)

      stub(InventoryDTO, :from_domain, fn inventory -> %InventoryDTO{
        id: inventory.id,
        veicule_id: inventory.veicule_id,
        price: inventory.price
      } end)

      # Act
      result = InventoryInternalController.get_all_to_sell()

      # Assert
      assert {:ok, dtos} = result
      assert length(dtos) == 1
    end

    test "returns error when use case fails" do
      # Arrange
      stub(VeiculesToSell, :execute, fn VeiculeRepository, InventoryRepository, SaleRepository ->
        {:error, :use_case_error}
      end)

      # Act
      result = InventoryInternalController.get_all_to_sell()

      # Assert
      assert {:error, :use_case_error} = result
    end
  end

  describe "get_all_sold/0" do
    test "successfully gets all sold inventories" do
      # Arrange
      inventories = [
        %Inventory{
          id: "inv-1",
          veicule_id: "v-1",
          price: 85000.00,
          veicule: %Veicule{id: "v-1", brand: "Honda", model: "Civic", year: 2024, color: "Preto"}
        }
      ]

      stub(VeiculesSold, :execute, fn VeiculeRepository, InventoryRepository, SaleRepository ->
        {:ok, inventories}
      end)

      stub(InventoryDTO, :from_domain, fn inventory -> %InventoryDTO{
        id: inventory.id,
        veicule_id: inventory.veicule_id,
        price: inventory.price
      } end)

      # Act
      result = InventoryInternalController.get_all_sold()

      # Assert
      assert {:ok, dtos} = result
      assert length(dtos) == 1
    end

    test "returns error when use case fails" do
      # Arrange
      stub(VeiculesSold, :execute, fn VeiculeRepository, InventoryRepository, SaleRepository ->
        {:error, :use_case_error}
      end)

      # Act
      result = InventoryInternalController.get_all_sold()

      # Assert
      assert {:error, :use_case_error} = result
    end
  end
end
