defmodule VeiculeStorage.Infra.Repo.VeiculeStorageRepo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :inventory_id, references(:inventories), type: :uuid, null: false
      add :payment_id, references(:payments), type: :uuid, null: false
      add :status, :string

      timestamps()
    end
  end
end
