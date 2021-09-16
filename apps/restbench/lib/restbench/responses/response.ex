defmodule Restbench.Responses.Response do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @allowed_codes [200, 431, 451] ++ Enum.to_list(400..429) ++ Enum.to_list(500..511)

  @implemented_types ["TEXT", "JSON"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "responses" do
    field :title, :string
    belongs_to :arrow, Restbench.Arrows.Arrow, on_replace: :nilify
    field :type, :string
    field :code, :integer
    field :text_body, :string
    field :json_body, :map

    timestamps()
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> maybe_cast_json_body(attrs)
    |> cast(attrs, [:title, :type, :code, :arrow_id, :text_body])
    |> validate_required([:title, :type, :code])
    |> validate_inclusion(:type, @implemented_types)
    |> validate_inclusion(:code, @allowed_codes)
    |> validate_body()
  end

  defp maybe_cast_json_body(changeset, %{"json_body" => json_body}), do: cast_json_body(changeset, json_body)
  defp maybe_cast_json_body(changeset, %{json_body: json_body}), do: cast_json_body(changeset, json_body)
  defp maybe_cast_json_body(changeset, _), do: changeset

  defp cast_json_body(changeset, json_body) do
    case Jason.decode(json_body) do
      {:ok, map} -> cast(changeset, %{json_body: map}, [:json_body])
      {:error, _} ->
        changeset
        |> cast(%{}, [])
        |> add_error(:json_body, "has invalid format")
    end
  end

  defp validate_body(changeset) do
    case get_field(changeset, :type) do
      "TEXT" -> validate_required(changeset, :text_body)
      "JSON" -> validate_required(changeset, :json_body)
      _ -> changeset
    end
  end

  def allowed_codes, do: @allowed_codes
  def implemented_types, do: @implemented_types

  def to_html(%__MODULE__{type: "TEXT", text_body: text_body}), do: text_body

  def to_html(%__MODULE__{type: "JSON", json_body: json_map}) do
    Jason.encode!(json_map, pretty: true)
  end

end
