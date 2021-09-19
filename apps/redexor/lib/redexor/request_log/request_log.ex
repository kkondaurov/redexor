defmodule Redexor.RequestLog do

  alias Redexor.ArrowApi.ApiResponse
  alias Redexor.Arrows.Arrow
  alias Redexor.RequestLog.RequestLogEntry
  alias Redexor.Repo

  def log(%Arrow{} = arrow, %ApiResponse{} = response, query_params, body_params) do
    attrs = %{
      arrow_id: arrow.id,
      response_code: response.code,
      latency: response.latency,
      response_body: build_response_body(response.payload),
      query_params: Jason.encode!(query_params),
      body_params: Jason.encode!(body_params)
    }

    %RequestLogEntry{}
    |> RequestLogEntry.changeset(attrs)
    |> Repo.insert!()
  end

  defp build_response_body(body) when is_binary(body), do: body
  defp build_response_body(body) when is_map(body), do: Jason.encode!(body)

end
