defmodule Redexor.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :arrow_id, references(:arrows, type: :uuid, on_delete: :nothing)
      add :type, :string
      add :code, :integer
      add :text_body, :text
      add :json_body, :map

      timestamps()
    end

    create index(:responses, [:arrow_id])

    alter table(:arrows) do
      add :response_id, references(:responses, type: :uuid, on_delete: :nothing)
    end
  end
end
