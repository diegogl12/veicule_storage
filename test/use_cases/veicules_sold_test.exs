defmodule VeiculeStorage.UseCases.VeiculesSoldTest do
  use ExUnit.Case, async: true
  import Mox

  alias VeiculeStorage.Domain.Entities.Inventory
  alias VeiculeStorage.Domain.Entities.Sale
  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.UseCases.VeiculesSold

  setup :verify_on_exit!

  describe "execute/3" do
    test "successfully returns inventories with sales (sold)" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 85000.00},
        %Inventory{id: "inv-2", veicule_id: "v-2", price: 95000.00},
        %Inventory{id: "inv-3", veicule_id: "v-3", price: 75000.00}
      ]

      sales = [
        %Sale{id: "sale-1", inventory_id: "inv-1", payment_id: "pay-1", status: "COMPLETED"},
        %Sale{id: "sale-2", inventory_id: "inv-3", payment_id: "pay-2", status: "COMPLETED"}
      ]

      veicules = [
        %Veicule{id: "v-1", brand: "Toyota", model: "Corolla", year: 2023, color: "Prata"},
        %Veicule{id: "v-3", brand: "Honda", model: "Civic", year: 2024, color: "Preto"}
      ]

      # Expectations
      expect(InventoryRepositoryMock, :get_all, fn -> {:ok, inventories} end)
      expect(SaleRepositoryMock, :get_all, fn -> {:ok, sales} end)
      expect(VeiculeRepositoryMock, :find_by_ids, fn ["v-1", "v-3"] -> {:ok, veicules} end)

      # Act
      result = VeiculesSold.execute(
        VeiculeRepositoryMock,
        InventoryRepositoryMock,
        SaleRepositoryMock
      )

      # Assert
      assert {:ok, sold_inventories} = result
      assert length(sold_inventories) == 2

      # Verifica que inv-2 (não vendido) não está na lista
      assert Enum.all?(sold_inventories, fn inv -> inv.id != "inv-2" end)

      # Verifica ordenação por preço
      assert Enum.at(sold_inventories, 0).price == 75000.00
      assert Enum.at(sold_inventories, 1).price == 85000.00
    end

    test "returns empty list when no inventories are sold" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 85000.00},
        %Inventory{id: "inv-2", veicule_id: "v-2", price: 95000.00}
      ]

      sales = []

      # Expectations
      expect(InventoryRepositoryMock, :get_all, fn -> {:ok, inventories} end)
      expect(SaleRepositoryMock, :get_all, fn -> {:ok, sales} end)
      expect(VeiculeRepositoryMock, :find_by_ids, fn [] -> {:ok, []} end)

      # Act
      result = VeiculesSold.execute(
        VeiculeRepositoryMock,
        InventoryRepositoryMock,
        SaleRepositoryMock
      )

      # Assert
      assert {:ok, []} = result
    end

    test "returns all inventories when all are sold" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 95000.00},
        %Inventory{id: "inv-2", veicule_id: "v-2", price: 85000.00}
      ]

      sales = [
        %Sale{id: "sale-1", inventory_id: "inv-1", payment_id: "pay-1", status: "COMPLETED"},
        %Sale{id: "sale-2", inventory_id: "inv-2", payment_id: "pay-2", status: "COMPLETED"}
      ]

      veicules = [
        %Veicule{id: "v-1", brand: "Toyota", model: "Corolla", year: 2023, color: "Prata"},
        %Veicule{id: "v-2", brand: "Honda", model: "Civic", year: 2024, color: "Preto"}
      ]

      # Expectations
      expect(InventoryRepositoryMock, :get_all, fn -> {:ok, inventories} end)
      expect(SaleRepositoryMock, :get_all, fn -> {:ok, sales} end)
      expect(VeiculeRepositoryMock, :find_by_ids, fn ["v-1", "v-2"] -> {:ok, veicules} end)

      # Act
      result = VeiculesSold.execute(
        VeiculeRepositoryMock,
        InventoryRepositoryMock,
        SaleRepositoryMock
      )

      # Assert
      assert {:ok, sold_inventories} = result
      assert length(sold_inventories) == 2

      # Verifica ordenação por preço
      assert Enum.at(sold_inventories, 0).price == 85000.00
      assert Enum.at(sold_inventories, 1).price == 95000.00
    end

    test "returns error when inventory repository fails" do
      # Arrange
      expect(InventoryRepositoryMock, :get_all, fn -> {:error, :database_error} end)

      # Act
      result = VeiculesSold.execute(
        VeiculeRepositoryMock,
        InventoryRepositoryMock,
        SaleRepositoryMock
      )

      # Assert
      assert {:error, :database_error} = result
    end

    test "returns error when sale repository fails" do
      # Arrange
      inventories = [
        %Inventory{id: "inv-1", veicule_id: "v-1", price: 85000.00}
      ]

      expect(InventoryRepositoryMock, :get_all, fn -> {:ok, inventories} end)
      expect(SaleRepositoryMock, :get_all, fn -> {:error, :database_error} end)

      # Act
      result = VeiculesSold.execute(
        VeiculeRepositoryMock,
        InventoryRepositoryMock,
        SaleRepositoryMock
      )

      # Assert
      assert {:error, :database_error} = result
    end
  end
end
