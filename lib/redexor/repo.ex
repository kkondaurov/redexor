defmodule Redexor.Repo do
  use Ecto.Repo,
    otp_app: :redexor,
    adapter: Ecto.Adapters.Postgres
end
