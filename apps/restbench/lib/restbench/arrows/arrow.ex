defmodule Restbench.Arrows.Arrow do
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
    belongs_to :server, Restbench.Servers.Server
    belongs_to :user, Restbench.Accounts.User

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
  end

  def allowed_methods, do: @allowed_methods
end
