defmodule VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepositoryTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.InventoryRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.InventorySchema

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "get/1" do
    test "successfully gets an inventory by id" do
      # Arrange
      inventory_id = "inventory-uuid-123"

      inventory_schema = %InventorySchema{
        id: inventory_id,
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      stub(Repo, :get, fn InventorySchema, ^inventory_id -> inventory_schema end)

      # Act
      result = InventoryRepository.get(inventory_id)

      # Assert
      assert {:ok, %Inventory{
        id: ^inventory_id,
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }} = result
    end

    test "returns error when inventory is not found" do
      # Arrange
      inventory_id = "non-existent-id"
      stub(Repo, :get, fn InventorySchema, ^inventory_id -> nil end)

      # Act
      result = InventoryRepository.get(inventory_id)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "create/1" do
    test "successfully creates an inventory" do
      # Arrange
      inventory = %Inventory{
        veicule_id: "veicule-uuid-123",
        price: 95000.00
      }

      inventory_schema = %InventorySchema{
        id: "new-inventory-uuid",
        veicule_id: "veicule-uuid-123",
        price: 95000.00
      }

      stub(InventorySchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:ok, inventory_schema} end)

      # Act
      result = InventoryRepository.create(inventory)

      # Assert
      assert {:ok, %Inventory{
        id: "new-inventory-uuid",
        veicule_id: "veicule-uuid-123",
        price: 95000.00
      }} = result
    end

    test "returns error when repository fails" do
      # Arrange
      inventory = %Inventory{
        veicule_id: "veicule-uuid-123",
        price: 75000.00
      }

      stub(InventorySchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:error, :database_error} end)

      # Act
      result = InventoryRepository.create(inventory)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "update/1" do
    test "successfully updates an inventory" do
      # Arrange
      inventory_id = "inventory-uuid-123"

      updated_inventory = %Inventory{
        id: inventory_id,
        veicule_id: "veicule-uuid-456",
        price: 99000.00
      }

      existing_schema = %InventorySchema{
        id: inventory_id,
        veicule_id: "veicule-uuid-456",
        price: 85000.00
      }

      updated_schema = %InventorySchema{
        id: inventory_id,
        veicule_id: "veicule-uuid-456",
        price: 99000.00
      }

      stub(Repo, :get, fn InventorySchema, ^inventory_id -> existing_schema end)
      stub(InventorySchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :update, fn :changeset -> {:ok, updated_schema} end)

      # Act
      result = InventoryRepository.update(updated_inventory)

      # Assert
      assert {:ok, %Inventory{
        id: ^inventory_id,
        veicule_id: "veicule-uuid-456",
        price: 99000.00
      }} = result
    end

    test "returns error when inventory is not found" do
      # Arrange
      inventory = %Inventory{
        id: "non-existent-id",
        veicule_id: "veicule-uuid-123",
        price: 85000.00
      }

      stub(Repo, :get, fn InventorySchema, "non-existent-id" -> nil end)

      # Act
      result = InventoryRepository.update(inventory)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "get_all/0" do
    test "successfully gets all inventories" do
      # Arrange
      inventory_schemas = [
        %InventorySchema{
          id: "inventory-1",
          veicule_id: "veicule-1",
          price: 85000.00
        },
        %InventorySchema{
          id: "inventory-2",
          veicule_id: "veicule-2",
          price: 95000.00
        }
      ]

      stub(Repo, :all, fn InventorySchema -> inventory_schemas end)

      # Act
      result = InventoryRepository.get_all()

      # Assert
      assert {:ok, inventories} = result
      assert length(inventories) == 2
      assert Enum.at(inventories, 0).id == "inventory-1"
      assert Enum.at(inventories, 1).id == "inventory-2"
    end

    test "returns empty list when no inventories exist" do
      # Arrange
      stub(Repo, :all, fn InventorySchema -> [] end)

      # Act
      result = InventoryRepository.get_all()

      # Assert
      assert {:ok, []} = result
    end
  end
end
