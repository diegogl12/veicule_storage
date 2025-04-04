defmodule VeiculeStorage.Infra.Repo.VeiculeStorageRepo.Migrations.CreateInventories do
  use Ecto.Migration

  def change do
    create table(:inventories) do
      add :veicule_id, references(:veicules), type: :uuid, null: false
      add :price, :float

      timestamps()
    end
  end
end
