defmodule Redexor.Repo.Local do
  use Ecto.Repo,
    otp_app: :redexor,
    adapter: Ecto.Adapters.Postgres

  # Dynamically configure the database url based on runtime environment.
  def init(_type, config) do
    {:ok, Keyword.put(config, :url, Fly.Postgres.database_url())}
  end
end

defmodule Redexor.Repo do
  use Fly.Repo, local_repo: Redexor.Repo.Local
end
