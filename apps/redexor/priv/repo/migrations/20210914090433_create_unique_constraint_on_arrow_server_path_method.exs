defmodule Redexor.Repo.Migrations.CreateUniqueConstraintOnArrowServerPathMethod do
  use Ecto.Migration

  def change do
    create unique_index(:arrows, [:server_id, :path, :method])
  end
end
