defmodule Redexor.Release do
  @moduledoc """
    Release tasks. Example:
    ```
    _build/prod/rel/redexor/bin/redexor eval "Redexor.Release.seed"
    ```
  """

  @app :redexor

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    migrate()
    Redexor.Release.Seeds.run()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(:fly_postgres)
    Application.load(@app)
    Application.ensure_all_started(@app)
  end
end
