import Config

config :veicule_storage, :external_payment_service,
  host: System.get_env("EXTERNAL_PAYMENT_SERVICE_HOST")
