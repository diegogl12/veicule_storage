defmodule VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepositoryTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.Infra.Repo.VeiculeStorageRepo, as: Repo
  alias VeiculeStorage.InterfaceAdapters.Repositories.Schemas.VeiculeSchema
  alias VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "get/1" do
    test "successfully gets a veicule by id" do
      # Arrange
      veicule_id = "veicule-uuid-123"

      veicule_schema = %VeiculeSchema{
        id: veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      stub(Repo, :get, fn VeiculeSchema, ^veicule_id -> veicule_schema end)

      # Act
      result = VeiculeRepository.get(veicule_id)

      # Assert
      assert {:ok, %Veicule{
        id: ^veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }} = result
    end

    test "returns error when veicule is not found" do
      # Arrange
      veicule_id = "non-existent-id"
      stub(Repo, :get, fn VeiculeSchema, ^veicule_id -> nil end)

      # Act
      result = VeiculeRepository.get(veicule_id)

      # Assert
      assert {:error, :not_found} = result
    end
  end

  describe "create/1" do
    test "successfully creates a veicule" do
      # Arrange
      veicule = %Veicule{
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      veicule_schema = %VeiculeSchema{
        id: "new-veicule-uuid",
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      stub(VeiculeSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:ok, veicule_schema} end)

      # Act
      result = VeiculeRepository.create(veicule)

      # Assert
      assert {:ok, %Veicule{
        id: "new-veicule-uuid",
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }} = result
    end

    test "returns error when repository fails" do
      # Arrange
      veicule = %Veicule{
        brand: "Ford",
        model: "Focus",
        year: 2023,
        color: "Azul"
      }

      stub(VeiculeSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :insert, fn :changeset -> {:error, :database_error} end)

      # Act
      result = VeiculeRepository.create(veicule)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "update/1" do
    test "successfully updates a veicule" do
      # Arrange
      veicule_id = "veicule-uuid-123"

      existing_veicule = %Veicule{
        id: veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      updated_veicule = %Veicule{
        id: veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      veicule_schema = %VeiculeSchema{
        id: veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      stub(Repo, :get, fn VeiculeSchema, ^veicule_id ->
        %VeiculeSchema{
          id: veicule_id,
          brand: "Toyota",
          model: "Corolla",
          year: 2023,
          color: "Prata"
        }
      end)

      stub(VeiculeSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :update, fn :changeset -> {:ok, veicule_schema} end)

      # Act
      result = VeiculeRepository.update(updated_veicule)

      # Assert
      assert {:ok, %Veicule{
        id: ^veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }} = result
    end

    test "returns error when veicule is not found" do
      # Arrange
      veicule = %Veicule{
        id: "non-existent-id",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      stub(Repo, :get, fn VeiculeSchema, "non-existent-id" -> nil end)

      # Act
      result = VeiculeRepository.update(veicule)

      # Assert
      assert {:error, :not_found} = result
    end

    test "returns error when repository update fails" do
      # Arrange
      veicule_id = "veicule-uuid-123"

      veicule = %Veicule{
        id: veicule_id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      stub(Repo, :get, fn VeiculeSchema, ^veicule_id ->
        %VeiculeSchema{
          id: veicule_id,
          brand: "Toyota",
          model: "Corolla",
          year: 2023,
          color: "Prata"
        }
      end)

      stub(VeiculeSchema, :changeset, fn _schema, _attrs -> :changeset end)
      stub(Repo, :update, fn :changeset -> {:error, :database_error} end)

      # Act
      result = VeiculeRepository.update(veicule)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "find_by_ids/1" do
    test "successfully finds veicules by ids" do
      # Arrange
      ids = ["uuid-1", "uuid-2"]

      veicule_schemas = [
        %VeiculeSchema{
          id: "uuid-1",
          brand: "Toyota",
          model: "Corolla",
          year: 2023,
          color: "Prata"
        },
        %VeiculeSchema{
          id: "uuid-2",
          brand: "Honda",
          model: "Civic",
          year: 2024,
          color: "Preto"
        }
      ]

      stub(Repo, :all, fn _query -> veicule_schemas end)

      # Act
      result = VeiculeRepository.find_by_ids(ids)

      # Assert
      assert {:ok, veicules} = result
      assert length(veicules) == 2
      assert Enum.at(veicules, 0).id == "uuid-1"
      assert Enum.at(veicules, 1).id == "uuid-2"
    end

    test "returns empty list when no veicules found" do
      # Arrange
      ids = ["non-existent-1", "non-existent-2"]
      stub(Repo, :all, fn _query -> [] end)

      # Act
      result = VeiculeRepository.find_by_ids(ids)

      # Assert
      assert {:ok, []} = result
    end
  end
end
