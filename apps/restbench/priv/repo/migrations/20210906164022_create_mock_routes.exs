defmodule Restbench.Repo.Migrations.CreateMockRoutes do
  use Ecto.Migration

  def change do
    create table(:mock_routes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :path, :string
      add :method, :string
      add :enabled, :boolean, default: false, null: false
      add :mock_server_id, references(:mock_servers, type: :uuid, on_delete: :nothing)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:mock_routes, [:mock_server_id])
    create index(:mock_routes, [:user_id])
    create index(:mock_routes, [:enabled])
  end
end
