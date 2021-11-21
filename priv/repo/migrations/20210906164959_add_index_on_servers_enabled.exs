defmodule Redexor.Repo.Migrations.AddIndexOnServersEnabled do
  use Ecto.Migration

  def change do
    create index(:servers, [:enabled])
  end
end
