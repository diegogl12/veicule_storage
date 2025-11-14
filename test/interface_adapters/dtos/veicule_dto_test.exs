defmodule VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTOTest do
  use ExUnit.Case, async: true

  alias VeiculeStorage.Domain.Entities.Veicule
  alias VeiculeStorage.InterfaceAdapters.DTOs.VeiculeDTO

  describe "to_domain/1" do
    test "converts DTO to domain entity successfully" do
      # Arrange
      dto = %VeiculeDTO{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }

      # Act
      result = VeiculeDTO.to_domain(dto)

      # Assert
      assert {:ok, %Veicule{
        id: "veicule-uuid-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2023,
        color: "Prata"
      }} = result
    end

    test "converts DTO without id to domain entity" do
      # Arrange
      dto = %VeiculeDTO{
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }

      # Act
      result = VeiculeDTO.to_domain(dto)

      # Assert
      assert {:ok, %Veicule{
        id: nil,
        brand: "Honda",
        model: "Civic",
        year: 2024,
        color: "Preto"
      }} = result
    end
  end

  describe "from_domain/1" do
    test "converts domain entity to DTO successfully" do
      # Arrange
      veicule = %Veicule{
        id: "veicule-uuid-456",
        brand: "Ford",
        model: "Focus",
        year: 2022,
        color: "Azul"
      }

      # Act
      result = VeiculeDTO.from_domain(veicule)

      # Assert
      assert %VeiculeDTO{
        id: "veicule-uuid-456",
        brand: "Ford",
        model: "Focus",
        year: 2022,
        color: "Azul"
      } = result
    end

    test "returns nil when domain is nil" do
      # Act
      result = VeiculeDTO.from_domain(nil)

      # Assert
      assert nil == result
    end
  end

  describe "from_map/1" do
    test "converts map with string keys to DTO successfully" do
      # Arrange
      map = %{
        "id" => "veicule-uuid-789",
        "brand" => "Chevrolet",
        "model" => "Onix",
        "year" => "2023",
        "color" => "Branco"
      }

      # Act
      result = VeiculeDTO.from_map(map)

      # Assert
      assert {:ok, %VeiculeDTO{
        id: "veicule-uuid-789",
        brand: "Chevrolet",
        model: "Onix",
        year: 2023,
        color: "Branco"
      }} = result
    end

    test "converts map with integer year to DTO successfully" do
      # Arrange
      map = %{
        "brand" => "Volkswagen",
        "model" => "Gol",
        "year" => 2021,
        "color" => "Vermelho"
      }

      # Act
      result = VeiculeDTO.from_map(map)

      # Assert
      assert {:ok, %VeiculeDTO{
        brand: "Volkswagen",
        model: "Gol",
        year: 2021,
        color: "Vermelho"
      }} = result
    end

    test "returns ok with nil when map is nil" do
      # Act
      result = VeiculeDTO.from_map(nil)

      # Assert
      assert {:ok, nil} = result
    end
  end
end
