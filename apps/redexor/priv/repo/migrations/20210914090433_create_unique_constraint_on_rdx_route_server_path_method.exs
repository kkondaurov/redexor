defmodule Redexor.Repo.Migrations.CreateUniqueConstraintOnRdxRouteServerPathMethod do
  use Ecto.Migration

  def change do
    create unique_index(:rdx_routes, [:server_id, :path, :method])
  end
end
