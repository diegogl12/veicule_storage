defmodule VeiculeStorage.MixProject do
  use Mix.Project

  def project do
    [
      app: :veicule_storage,
      version: "0.1.0",
      elixir: "~> 1.18-rc",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {VeiculeStorage.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:hackney, "~> 1.9"},
      {:jason, "~> 1.4.4"},
      {:mint, "~> 1.0"},
      {:mox, "~> 1.0", only: :test},
      {:mimic, "~> 1.10", only: :test},
      {:excoveralls, "~> 0.18", only: :test},
      {:plug_cowboy, "~> 2.7.3"},
      {:postgrex, ">= 0.0.0"},
      {:req, "~> 0.4.0"},
      {:tesla, "~> 1.14"},
      {:uuid, "~> 1.1"},
    ]
  end
end
