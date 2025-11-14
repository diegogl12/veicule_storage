defmodule VeiculeStorage.Infra.Web.Controllers.VeiculeControllerTest do
  use ExUnit.Case, async: false
  import Mimic

  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.Infra.Web.Controllers.VeiculeController
  alias VeiculeStorage.InterfaceAdapters.Controllers.VeiculeInternalController
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO

  setup :set_mimic_global
  setup :verify_on_exit!

  describe "create_veicule/1" do
    test "successfully creates a veicule" do
      # Arrange
      params = %{
        "brand" => "Toyota",
        "model" => "Corolla",
        "year" => "2023",
        "color" => "Prata"
      }

      dto = %VeiculeDTO{
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

      stub(VeiculeDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(VeiculeInternalController, :create, fn ^dto -> {:ok, created_veicule} end)

      # Act
      result = VeiculeController.create_veicule(params)

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
      params = %{
        "brand" => "Invalid"
      }

      stub(VeiculeDTO, :from_map, fn ^params -> {:error, :invalid_params} end)

      # Act
      result = VeiculeController.create_veicule(params)

      # Assert
      assert {:error, :invalid_params} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      params = %{
        "brand" => "Honda",
        "model" => "Civic",
        "year" => "2024",
        "color" => "Preto"
      }

      dto = %VeiculeDTO{
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      stub(VeiculeDTO, :from_map, fn ^params -> {:ok, dto} end)
      stub(VeiculeInternalController, :create, fn ^dto -> {:error, :database_error} end)

      # Act
      result = VeiculeController.create_veicule(params)

      # Assert
      assert {:error, :database_error} = result
    end
  end

  describe "update_veicule/2" do
    test "successfully updates a veicule" do
      # Arrange
      params = %{
        "brand" => "Toyota",
        "model" => "Corolla",
        "year" => "2023",
        "color" => "Vermelho"
      }

      id = "veicule-uuid-123"

      dto = %VeiculeDTO{
        id: id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      updated_veicule = %Veicule{
        id: id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Vermelho"
      }

      stub(VeiculeDTO, :from_map, fn _map -> {:ok, dto} end)
      stub(VeiculeInternalController, :update, fn ^dto -> {:ok, updated_veicule} end)

      # Act
      result = VeiculeController.update_veicule(params, id)

      # Assert
      assert {:ok, %Veicule{
        id: ^id,
        color: "Vermelho"
      }} = result
    end

    test "returns error when DTO conversion fails" do
      # Arrange
      params = %{"brand" => "Invalid"}
      id = "veicule-uuid-123"

      stub(VeiculeDTO, :from_map, fn _map -> {:error, :invalid_params} end)

      # Act
      result = VeiculeController.update_veicule(params, id)

      # Assert
      assert {:error, :invalid_params} = result
    end

    test "returns error when internal controller fails" do
      # Arrange
      params = %{
        "brand" => "Toyota",
        "model" => "Corolla",
        "year" => "2023",
        "color" => "Azul"
      }

      id = "non-existent-id"

      dto = %VeiculeDTO{
        id: id,
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Azul"
      }

      stub(VeiculeDTO, :from_map, fn _map -> {:ok, dto} end)
      stub(VeiculeInternalController, :update, fn ^dto -> {:error, :not_found} end)

      # Act
      result = VeiculeController.update_veicule(params, id)

      # Assert
      assert {:error, :not_found} = result
    end
  end
end
