defmodule Restbench.Repo do
  use Ecto.Repo,
    otp_app: :restbench,
    adapter: Ecto.Adapters.Postgres
end
