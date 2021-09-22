defmodule Redexor.RequestLog do
  @moduledoc false

  import Ecto.Query
  alias Redexor.RequestHandler.ApiResponse
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.RequestLog.RequestLogEntry
  alias Redexor.Repo

  @default_per_page 50

  @spec log!(RdxRoute.t(), ApiResponse.t(), map(), map()) :: RequestLogEntry.t() | no_return()
  def log!(%RdxRoute{} = rdx_route, %ApiResponse{} = api_response, query_params, body_params) do
    attrs = %{
      rdx_route_id: rdx_route.id,
      response_code: api_response.code,
      latency: api_response.latency,
      response_body: build_response_body(api_response.payload),
      query_params: URI.encode_query(query_params),
      body_params: Jason.encode!(body_params, pretty: true)
    }

    %RequestLogEntry{}
    |> RequestLogEntry.changeset(attrs)
    |> Repo.insert!(returning: true)
  end

  defp build_response_body(body) when is_binary(body), do: body
  defp build_response_body(body) when is_map(body), do: Jason.encode!(body, pretty: true)

  def list(%RdxRoute{id: rdx_route_id}, per_page \\ @default_per_page) do
    RequestLogEntry
    |> where([e], e.rdx_route_id == ^rdx_route_id)
    |> order_by([e], desc: e.id)
    |> limit(^per_page)
    |> Repo.all()
  end
end
