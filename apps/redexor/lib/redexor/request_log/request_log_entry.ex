defmodule Redexor.RequestLog.RequestLogEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]

  @foreign_key_type :binary_id
  schema "request_log" do
    belongs_to :arrow, Redexor.Arrows.Arrow
    field :response_code, :integer
    field :latency, :integer
    field :inserted_at, :utc_datetime
    field :response_body, :string
    field :query_params, :string
    field :body_params, :string
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:arrow_id, :response_code, :latency, :inserted_at, :response_body, :query_params, :body_params])
    |> validate_required([:arrow_id, :response_code, :latency])
  end
end
