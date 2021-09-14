defmodule Restbench.Servers.Server do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "servers" do
    field :enabled, :boolean, default: false
    field :title, :string
    belongs_to :user, Restbench.Accounts.User

    has_many :arrows, Restbench.Arrows.Arrow

    timestamps()
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:title, :enabled, :user_id])
    |> validate_required([:title, :enabled, :user_id])
  end
end