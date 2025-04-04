defmodule VeiculeStorage.Infra.Repo.VeiculeStorageRepo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :payment_method, :string
      add :payment_value, :float
      add :status, :string
      add :payment_date, :naive_datetime

      timestamps()
    end
  end
end
