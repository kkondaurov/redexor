defmodule Redexor.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      app: :redexor,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        redexor: [
          version: "0.1.0",
          applications: [redexor: :permanent]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Redexor.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_psql_extras, "~> 0.6"},
      {:ecto_sql, "~> 3.4"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:floki, ">= 0.30.0", only: :test},
      {:hackney, "~> 1.9"},
      {:phoenix, "~> 1.6.0-rc.0", [env: :prod, repo: "hexpm", hex: "phoenix", override: true]},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.16.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.4"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:timex, "~> 3.7"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:libcluster, "~> 3.3"},
      {:fly_postgres, "~> 0.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
