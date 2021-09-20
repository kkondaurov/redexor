defmodule Redexor.RequestLog do
  @moduledoc false

  import Ecto.Query
  alias Redexor.ArrowApi.ApiResponse
  alias Redexor.Arrows.Arrow
  alias Redexor.RequestLog.RequestLogEntry
  alias Redexor.Repo

  @default_per_page 50

  @spec log!(Arrow.t(), ApiResponse.t(), map(), map()) :: RequestLogEntry.t() | no_return()
  def log!(%Arrow{} = arrow, %ApiResponse{} = response, query_params, body_params) do
    attrs = %{
      arrow_id: arrow.id,
      response_code: response.code,
      latency: response.latency,
      response_body: build_response_body(response.payload),
      query_params: URI.encode_query(query_params),
      body_params: Jason.encode!(body_params, pretty: true),
    }

    %RequestLogEntry{}
    |> RequestLogEntry.changeset(attrs)
    |> Repo.insert!(returning: true)
  end

  defp build_response_body(body) when is_binary(body), do: body
  defp build_response_body(body) when is_map(body), do: Jason.encode!(body, pretty: true)

  def list(%Arrow{id: arrow_id}, per_page \\ @default_per_page) do
    RequestLogEntry
    |> where([e], e.arrow_id == ^arrow_id)
    |> order_by([e], desc: e.id)
    |> limit(^per_page)
    |> Repo.all()
  end

end
