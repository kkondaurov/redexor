defmodule Redexor.ResponseTemplates.ResponseTemplate do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @allowed_codes [200, 431, 451] ++ Enum.to_list(400..429) ++ Enum.to_list(500..511)

  @allowed_latencies [0, 50, 100, 200, 500, 1_000, 2_000, 5_000, 10_000, 20_000]

  @implemented_types ["TEXT", "JSON"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "response_templates" do
    field :title, :string
    belongs_to :rdx_route, Redexor.RdxRoutes.RdxRoute
    field :selected, :boolean, default: false
    field :type, :string
    field :code, :integer
    field :latency, :integer, default: 0
    field :text_body, :string
    field :json_body, :map

    timestamps()
  end

  @doc false
  def changeset(response_template, attrs) do
    response_template
    |> cast(attrs, [:title, :type, :code, :rdx_route_id, :selected, :latency, :text_body])
    |> cast_json_body(attrs)
    |> validate_required([:title, :type, :code, :selected])
    |> validate_inclusion(:type, @implemented_types)
    |> validate_inclusion(:code, @allowed_codes)
    |> validate_inclusion(:latency, @allowed_latencies)
    |> validate_required_body()
  end

  defp validate_required_body(changeset) do
    case get_field(changeset, :type) do
      "TEXT" ->
        validate_required(changeset, :text_body)

      "JSON" ->
        validate_required(changeset, :json_body)

      _ -> changeset
    end
  end

  defp cast_json_body(changeset, %{"json_body" => json_body}), do: do_cast_json_body(changeset, json_body)
  defp cast_json_body(changeset, %{json_body: json_body}), do: do_cast_json_body(changeset, json_body)
  defp cast_json_body(changeset, _), do: changeset

  defp do_cast_json_body(changeset, ""), do: cast(changeset, %{json_body: %{}}, [:json_body])
  defp do_cast_json_body(changeset, nil), do: cast(changeset, %{json_body: %{}}, [:json_body])
  defp do_cast_json_body(changeset, json_body) when is_binary(json_body) do
    case Jason.decode(json_body) do
      {:ok, map} ->
        cast(changeset, %{json_body: map}, [:json_body])

      {:error, _} ->
        changeset
        |> cast(%{}, [])
        |> add_error(:json_body, "has invalid format")
    end
  end
  defp do_cast_json_body(changeset, _), do: add_error(changeset, :json_body, "has invalid format")

  def allowed_codes, do: @allowed_codes
  def implemented_types, do: @implemented_types
  def allowed_latencies, do: @allowed_latencies

  def to_html(%__MODULE__{type: "TEXT", text_body: text_body}), do: text_body

  def to_html(%__MODULE__{type: "JSON", json_body: json_map}) do
    Jason.encode!(json_map, pretty: true)
  end

end
