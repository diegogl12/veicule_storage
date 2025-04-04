import Config

config :veicule_storage, VeiculeStorage.Infra.Repo.VeiculeStorageRepo,
  database: System.get_env("VEICULE_STORAGE_DATABASE", "veicule_storage_db"),
  username: System.get_env("VEICULE_STORAGE_USERNAME", "postgres"),
  password: System.get_env("VEICULE_STORAGE_PASSWORD", "postgres"),
  hostname: System.get_env("VEICULE_STORAGE_HOSTNAME", "postgres"),
  migration_primary_key: [type: :uuid]

config :veicule_storage, ecto_repos: [VeiculeStorage.Infra.Repo.VeiculeStorageRepo]

config :veicule_storage, :api,
  port: System.get_env("VEICULE_STORAGE_ENDPOINT_PORT", "4000") |> String.to_integer()

config :tesla, :adapter, Tesla.Adapter.Mint

import_config "#{config_env()}.exs"
