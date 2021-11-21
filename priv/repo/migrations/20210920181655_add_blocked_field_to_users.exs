defmodule Redexor.Repo.Migrations.AddBlockedFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :blocked, :boolean, default: false
    end
  end
end
