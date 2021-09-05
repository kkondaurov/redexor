defmodule Restbench.MockServers.MockServer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mock_servers" do
    field :enabled, :boolean, default: false
    field :title, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(mock_server, attrs) do
    mock_server
    |> cast(attrs, [:title, :enabled])
    |> validate_required([:title, :enabled])
  end
end
