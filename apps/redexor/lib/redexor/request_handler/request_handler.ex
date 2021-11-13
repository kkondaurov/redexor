defmodule Redexor.RequestHandler do
  @moduledoc """
  Context for Route API business logic.
  """

  require Logger

  alias Redexor.RdxRoutes
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.RequestHandler.ApiResponse

  @new_request_topic "new_api_request"

  @spec handle(String.t(), String.t(), String.t(), map(), map()) :: ApiResponse.t()
  def handle(server_id, method, path, query_params, body_params) do
    with {:server_id_valid, {:ok, server_uuid}} <- {:server_id_valid, Ecto.UUID.cast(server_id)},
         {:rdx_route_exists, %RdxRoute{} = rdx_route} <-
           {:rdx_route_exists, RdxRoutes.find_enabled_route(server_uuid, method, path)} do
      Logger.info(
        message: "Processed API request",
        server_id: server_id,
        method: method,
        path: path,
        rdx_route_id: rdx_route.id,
        response_id: rdx_route.response_template && rdx_route.response_template.id
      )

      api_response = ApiResponse.build(rdx_route.response_template)
      broadcast(rdx_route, api_response, query_params, body_params)
      api_response
    else
      {:server_id_valid, _} ->
        Logger.warn(
          message: "Server id is invalid",
          error: 400,
          server_id: server_id,
          method: method,
          path: path
        )

        %ApiResponse{code: 400}

      {:rdx_route_exists, nil} ->
        Logger.warn(
          message: "Server or Route not found or disabled",
          error: 404,
          server_id: server_id,
          method: method,
          path: path
        )

        %ApiResponse{code: 404}
    end
  end

  defp broadcast(rdx_route, response_template, query_params, body_params) do
    Phoenix.PubSub.broadcast!(
      Redexor.PubSub,
      @new_request_topic,
      {:new_request,
       %{
         rdx_route: rdx_route,
         response_template: response_template,
         query_params: query_params,
         body_params: body_params
       }}
    )
  end
end
