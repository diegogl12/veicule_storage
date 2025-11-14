defmodule VeiculeStorage.InterfaceAdapters.Repositories.SaleRepositoryTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.SaleRepository
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.SaleSchema

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "get/1" do
    test "successfully gets a sale by id" do
      # Arrange
      sale_id = "sale-uuid-123"

      sale_schema = %SaleSchema{
        id: sale_id,
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      stub(Repo, :get, fn SaleSchema, ^sale_id -> sale_schema end)

      # Act
      result = SaleRepository.get(sale_id)

      # Assert
      assert {:ok, %Sale{
        id: ^sale_id,
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }} = result
    end

    test "returns error when sale is not found" do
      # Arrange
      sale_id = "non-existent-id"
      stub(Repo, :get, fn SaleSchema, ^sale_id -> nil end)

      # Act
      result = SaleRepository.get(sale_id)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "create/1" do
    test "successfully creates a sale" do
      # Arrange
      sale = %Sale{
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }

      sale_schema = %SaleSchema{
        id: "new-sale-uuid",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }

      stub(SaleSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:ok, sale_schema} end)

      # Act
      result = SaleRepository.create(sale)

      # Assert
      assert {:ok, %Sale{
        id: "new-sale-uuid",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }} = result
    end

    test "returns error when repository fails" do
      # Arrange
      sale = %Sale{
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }

      stub(SaleSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:error, :database_error} end)

      # Act
      result = SaleRepository.create(sale)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "update/1" do
    test "successfully updates a sale" do
      # Arrange
      sale_id = "sale-uuid-123"

      updated_sale = %Sale{
        id: sale_id,
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_COMPLETED"
      }

      existing_schema = %SaleSchema{
        id: sale_id,
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "IN_PROGRESS"
      }

      updated_schema = %SaleSchema{
        id: sale_id,
        inventory_id: "inventory-uuid-456",
        payment_id: "payment-uuid-789",
        status: "PAYMENT_COMPLETED"
      }

      stub(Repo, :get, fn SaleSchema, ^sale_id -> existing_schema end)
      stub(SaleSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :update, fn :changeset -> {:ok, updated_schema} end)

      # Act
      result = SaleRepository.update(updated_sale)

      # Assert
      assert {:ok, %Sale{
        id: ^sale_id,
        status: "PAYMENT_COMPLETED"
      }} = result
    end

    test "returns error when sale is not found" do
      # Arrange
      sale = %Sale{
        id: "non-existent-id",
        inventory_id: "inventory-uuid-123",
        payment_id: "payment-uuid-456",
        status: "IN_PROGRESS"
      }

      stub(Repo, :get, fn SaleSchema, "non-existent-id" -> nil end)

      # Act
      result = SaleRepository.update(sale)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "get_by_inventory_id/1" do
    test "successfully gets a sale by inventory_id" do
      # Arrange
      inventory_id = "inventory-uuid-123"

      sale_schema = %SaleSchema{
        id: "sale-uuid-456",
        inventory_id: inventory_id,
        payment_id: "payment-uuid-789",
        status: "PAYMENT_COMPLETED"
      }

      stub(Repo, :get_by, fn SaleSchema, [inventory_id: ^inventory_id] -> sale_schema end)

      # Act
      result = SaleRepository.get_by_inventory_id(inventory_id)

      # Assert
      assert {:ok, %Sale{
        id: "sale-uuid-456",
        inventory_id: ^inventory_id,
        payment_id: "payment-uuid-789",
        status: "PAYMENT_COMPLETED"
      }} = result
    end

    test "returns error when sale is not found" do
      # Arrange
      inventory_id = "non-existent-inventory"
      stub(Repo, :get_by, fn SaleSchema, [inventory_id: ^inventory_id] -> nil end)

      # Act
      result = SaleRepository.get_by_inventory_id(inventory_id)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "get_all/0" do
    test "successfully gets all sales" do
      # Arrange
      sale_schemas = [
        %SaleSchema{
          id: "sale-1",
          inventory_id: "inventory-1",
          payment_id: "payment-1",
          status: "IN_PROGRESS"
        },
        %SaleSchema{
          id: "sale-2",
          inventory_id: "inventory-2",
          payment_id: "payment-2",
          status: "PAYMENT_COMPLETED"
        }
      ]

      stub(Repo, :all, fn SaleSchema -> sale_schemas end)

      # Act
      result = SaleRepository.get_all()

      # Assert
      assert {:ok, sales} = result
      assert length(sales) == 2
      assert Enum.at(sales, 0).id == "sale-1"
      assert Enum.at(sales, 1).id == "sale-2"
    end

    test "returns empty list when no sales exist" do
      # Arrange
      stub(Repo, :all, fn SaleSchema -> [] end)

      # Act
      result = SaleRepository.get_all()

      # Assert
      assert {:ok, []} = result
    end
  end
end
