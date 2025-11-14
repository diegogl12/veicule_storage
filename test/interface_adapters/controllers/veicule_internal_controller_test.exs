defmodule VeiculeStorage.InterfaceAdapters.Controllers.VeiculeInternalControllerTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.InterfaceAdapters.Controllers.VeiculeInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO
  alias VeiculeStorage.InterfaceAdapters.Repositories.VeiculeRepository

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "create/1" do
    test "successfully creates a veicule" do
      # Arrange
      dto = %VeiculeDTO{
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      veicule_domain = %Veicule{
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      created_veicule = %Veicule{
        id: "new-uuid",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      stub(VeiculeDTO, :to_domain, fn ^dto -> {:ok, veicule_domain} end)
      stub(VeiculeRepository, :create, fn ^veicule_domain -> {:ok, created_veicule} end)

      # Act
      result = VeiculeInternalController.create(dto)

      # Assert
      assert {:ok, %Veicule{
        id: "new-uuid",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      dto = %VeiculeDTO{
        brand: "Invalid",
        model: "Invalid",
        year: 2023,
        color: "Invalid"
      }

      stub(VeiculeDTO, :to_domain, fn ^dto -> {:error, :invalid_data} end)

      # Act
      result = VeiculeInternalController.create(dto)

      # Assert
      assert {:error, :invalid_data} = result
    end

    test "returns error when repository fails" do
      # Arrange
      dto = %VeiculeDTO{
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      veicule_domain = %Veicule{
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      stub(VeiculeDTO, :to_domain, fn ^dto -> {:ok, veicule_domain} end)
      stub(VeiculeRepository, :create, fn ^veicule_domain -> {:error, :database_error} end)

      # Act
      result = VeiculeInternalController.create(dto)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "update/1" do
    test "successfully updates a veicule" do
      # Arrange
      dto = %VeiculeDTO{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      veicule_domain = %Veicule{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      updated_veicule = %Veicule{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      stub(VeiculeDTO, :to_domain, fn ^dto -> {:ok, veicule_domain} end)
      stub(VeiculeRepository, :update, fn ^veicule_domain -> {:ok, updated_veicule} end)

      # Act
      result = VeiculeInternalController.update(dto)

      # Assert
      assert {:ok, %Veicule{
        id: "veicule-uuid-123",
        color: "Vermelho"
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      dto = %VeiculeDTO{
        id: "veicule-uuid-123",
        brand: "Invalid",
        model: "Invalid",
        year: 2023,
        color: "Invalid"
      }

      stub(VeiculeDTO, :to_domain, fn ^dto -> {:error, :invalid_data} end)

      # Act
      result = VeiculeInternalController.update(dto)

      # Assert
      assert {:error, :invalid_data} = result
    end

    test "returns error when repository update fails" do
      # Arrange
      dto = %VeiculeDTO{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Azul"
      }

      veicule_domain = %Veicule{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Azul"
      }

      stub(VeiculeDTO, :to_domain, fn ^dto -> {:ok, veicule_domain} end)
      stub(VeiculeRepository, :update, fn ^veicule_domain -> {:error, :not_found} end)

      # Act
      result = VeiculeInternalController.update(dto)

      # Assert
      assert {:error, :not_found} = result
    end
  end
end
