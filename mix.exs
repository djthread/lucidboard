defmodule Lucidboard.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :lucidboard,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      mod: {Lucidboard.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ueberauth,
        :toml,
        :toml_transformer,
        :scrivener_ecto
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:focus, "~> 0.3.5"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:mix_test_watch, "~> 0.8", only: :dev, runtime: false},
      {:distillery, "~> 2.0"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:toml_transformer,
       git: "https://github.com/djthread/toml_transformer.git", app: false},
      {:ueberauth_github, "~> 0.7"},
      {:ueberauth_pingfed,
       git: "https://github.com/borodark/ueberauth_pingfed.git"},
      {:timex, "~> 3.1"},
      {:scrivener_ecto, "~> 2.0"},
      {:ecto_enum, "~> 1.2"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      lint: "credo --strict"
    ]
  end
end
