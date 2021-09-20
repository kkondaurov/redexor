defmodule Redexor.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :rdx_route_id, references(:rdx_routes, type: :uuid, on_delete: :delete_all)
      add :selected, :boolean, default: false
      add :type, :string
      add :code, :integer
      add :text_body, :text
      add :json_body, :map

      timestamps()
    end

    create index(:responses, [:rdx_route_id])
    create unique_index(:responses, [:rdx_route_id, :selected], where: "selected = true")
  end
end
