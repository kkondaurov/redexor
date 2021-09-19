defmodule Redexor.Responses.Response do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @allowed_codes [200, 431, 451] ++ Enum.to_list(400..429) ++ Enum.to_list(500..511)

  @allowed_latencies [0, 50, 100, 200, 500, 1_000, 2_000]

  @implemented_types ["TEXT", "JSON"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "responses" do
    field :title, :string
    belongs_to :arrow, Redexor.Arrows.Arrow
    field :selected, :boolean, default: false
    field :type, :string
    field :code, :integer
    field :latency, :integer, default: 0
    field :text_body, :string
    field :json_body, :map

    timestamps()
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:title, :type, :code, :arrow_id, :selected, :latency])
    |> validate_required([:title, :type, :code, :selected])
    |> validate_inclusion(:type, @implemented_types)
    |> validate_inclusion(:code, @allowed_codes)
    |> validate_inclusion(:latency, @allowed_latencies)
    |> validate_body(attrs)
  end

  defp validate_body(changeset, attrs) do
    case get_field(changeset, :type) do
      "TEXT" ->
        changeset
        |> cast(attrs, [:text_body])
        |> validate_required(:text_body)

      "JSON" ->
        changeset
        |> cast_json_body(attrs)
        |> validate_required(:json_body)

      _ -> changeset
    end
  end

  defp cast_json_body(changeset, %{"json_body" => json_body}), do: do_cast_json_body(changeset, json_body)
  defp cast_json_body(changeset, %{json_body: json_body}), do: do_cast_json_body(changeset, json_body)
  defp cast_json_body(changeset, _), do: changeset

  defp do_cast_json_body(changeset, json_body) do
    case Jason.decode(json_body) do
      {:ok, map} ->
        cast(changeset, %{json_body: map}, [:json_body])

      {:error, _} ->
        changeset
        |> cast(%{}, [])
        |> add_error(:json_body, "has invalid format")
    end
  end

  def allowed_codes, do: @allowed_codes
  def implemented_types, do: @implemented_types
  def allowed_latencies, do: @allowed_latencies

  def to_html(%__MODULE__{type: "TEXT", text_body: text_body}), do: text_body

  def to_html(%__MODULE__{type: "JSON", json_body: json_map}) do
    Jason.encode!(json_map, pretty: true)
  end

end
