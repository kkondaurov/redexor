defmodule Redexor.Repo.Migrations.CreateArrows do
  use Ecto.Migration

  def change do
    create table(:arrows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :path, :string
      add :method, :string
      add :enabled, :boolean, default: false, null: false
      add :server_id, references(:servers, type: :uuid, on_delete: :nothing)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)

      timestamps()
    end

    create index(:arrows, [:server_id])
    create index(:arrows, [:user_id])
    create index(:arrows, [:enabled])
  end
end
