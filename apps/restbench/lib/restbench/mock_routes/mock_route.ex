defmodule Restbench.MockRoutes.MockRoute do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @allowed_methods ["GET", "POST", "PUT", "PATCH", "DELETE"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mock_routes" do
    field :enabled, :boolean, default: false
    field :method, :string
    field :path, :string
    field :title, :string
    belongs_to :mock_server, Restbench.MockServers.MockServer
    belongs_to :user, Restbench.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(mock_route, attrs) do
    mock_route
    |> cast(attrs, [:title, :path, :method, :enabled])
    |> validate_required([:title, :path, :method, :enabled])
    |> validate_inclusion(:method, @allowed_methods)
  end

  def allowed_methods, do: @allowed_methods
end
