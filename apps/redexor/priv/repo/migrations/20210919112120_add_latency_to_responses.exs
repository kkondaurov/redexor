defmodule Redexor.Repo.Migrations.AddLatencyToResponses do
  use Ecto.Migration

  def change do
    alter table(:responses) do
      add :latency, :integer, default: 0
    end
  end
end
