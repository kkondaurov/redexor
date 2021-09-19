defmodule Redexor.Arrows.Arrow do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @allowed_methods ["GET", "POST", "PUT", "PATCH", "DELETE"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "arrows" do
    field :enabled, :boolean, default: false
    field :method, :string
    field :path, :string
    field :title, :string
    belongs_to :server, Redexor.Servers.Server
    belongs_to :user, Redexor.Accounts.User
    # currently selected response
    has_one :response, Redexor.Responses.Response
    # all the route responses
    has_many :responses, Redexor.Responses.Response

    timestamps()
  end

  @doc false
  def changeset(arrow, attrs) do
    arrow
    |> cast(attrs, [:title, :path, :method, :enabled])
    |> validate_required([:title, :path, :method, :enabled])
    |> validate_inclusion(:method, @allowed_methods)
    |> update_change(:path, fn path ->
      if String.starts_with?(path, "/") do
        path
      else
        "/" <> path
      end
    end)
    |> unique_constraint([:server_id, :path, :method],
      message: "This server already has a route with the above path and method"
    )
  end

  def allowed_methods, do: @allowed_methods
end
