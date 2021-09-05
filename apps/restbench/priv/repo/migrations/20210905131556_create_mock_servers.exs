defmodule Restbench.Repo.Migrations.CreateMockServers do
  use Ecto.Migration

  def change do
    create table(:mock_servers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :enabled, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:mock_servers, [:user_id])
  end
end
