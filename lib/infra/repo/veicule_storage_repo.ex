defmodule VeiculeStorage.Infra.Repo.VeiculeStorageRepo do
  use Ecto.Repo,
    otp_app: :veicule_storage,
    adapter: Ecto.Adapters.Postgres
end
