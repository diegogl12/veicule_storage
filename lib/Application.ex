defmodule VeiculeStorage.Application do
  use Application
  require Logger

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: VeiculeStorage.Supervisor]

    Logger.info("The server has started at port #{port()}...")

    Supervisor.start_link(children(Mix.env()), opts)
  end

  defp children(:test), do: []
  defp children(_), do: [
    VeiculeStorage.Infra.Repo.VeiculeStorageRepo,
    {Plug.Cowboy, scheme: :http, plug: VeiculeStorage.Infra.Web.Endpoints, options: [port: port()]},
  ]

  defp port, do: Application.get_env(:veicule_storage, :api) |> Keyword.get(:port)
end
