defmodule VeiculeStorage.Infra.Repo.VeiculeStorageRepo.Migrations.CreateVeicules do
  use Ecto.Migration

  def change do
    create table(:veicules) do
      add :brand, :string
      add :model, :string
      add :year, :integer
      add :color, :string

      timestamps()
    end
  end
end
