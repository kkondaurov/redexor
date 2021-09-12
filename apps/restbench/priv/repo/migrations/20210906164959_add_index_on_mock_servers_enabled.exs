defmodule Restbench.Repo.Migrations.AddIndexOnMockServersEnabled do
  use Ecto.Migration

  def change do
    create index(:mock_servers, [:enabled])
  end
end
