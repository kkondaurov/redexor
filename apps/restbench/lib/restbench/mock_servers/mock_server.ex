defmodule Restbench.MockServers.MockServer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mock_servers" do
    field :enabled, :boolean, default: false
    field :title, :string
    belongs_to :user, Restbench.Accounts.User

    has_many :mock_routes, Restbench.MockRoutes.MockRoute

    timestamps()
  end

  @doc false
  def changeset(mock_server, attrs) do
    mock_server
    |> cast(attrs, [:title, :enabled, :user_id])
    |> validate_required([:title, :enabled, :user_id])
  end
end
