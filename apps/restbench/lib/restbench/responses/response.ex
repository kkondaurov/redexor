defmodule Restbench.Responses.Response do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @allowed_codes [200, 400..429, 431, 451, 500..511]

  @implemented_types ["TEXT", "JSON"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "arrows" do
    field :title, :string
    belongs_to :arrow, Restbench.Arrows.Arrow
    field :type, :string
    field :code, :integer
    field :text_body, :string
    field :json_body, :map

    timestamps()
  end

  @doc false
  def changeset(arrow, attrs) do
    arrow
    |> cast(attrs, [:title, :text_body, :json_body])
    |> validate_required([:title])
    |> validate_inclusion(:type, @implemented_types)
    |> validate_inclusion(:code, @allowed_codes)
    |> validate_body()
  end

  defp validate_body(changeset) do
    case get_field(changeset, :type) do
      "TEXT" -> validate_required(changeset, :text_body)
      "JSON" -> validate_required(changeset, :json_body)
    end
  end

  def allowed_codes, do: @allowed_codes
  def implemented_types, do: @implemented_types
end
