defmodule Redexor.Repo.Migrations.CreateRdxRoutes do
  use Ecto.Migration

  def change do
    create table(:rdx_routes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :path, :string
      add :method, :string
      add :enabled, :boolean, default: false, null: false
      add :server_id, references(:servers, type: :uuid, on_delete: :delete_all)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:rdx_routes, [:server_id])
    create index(:rdx_routes, [:user_id])
    create index(:rdx_routes, [:enabled])
  end
end
