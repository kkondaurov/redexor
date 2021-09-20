defmodule Redexor.RequestHandler do
  @moduledoc """
  Context for Route API business logic.
  """

  require Logger

  alias Redexor.RequestHandler.ApiResponse
  alias Redexor.Arrows
  alias Redexor.Arrows.Arrow

  @spec handle(String.t(), String.t(), String.t(), map(), map()) :: ApiResponse.t()
  def handle(server_id, method, path, query_params, body_params) do
    with {:server_id_valid, {:ok, server_uuid}} <- {:server_id_valid, Ecto.UUID.cast(server_id)},
         {:arrow_exists, %Arrow{} = arrow} <-
           {:arrow_exists, Arrows.find_enabled_route(server_uuid, method, path)} do
      Logger.info(
        message: "Processed API request",
        server_id: server_id,
        method: method,
        path: path,
        arrow_id: arrow.id,
        response_id: arrow.response.id
      )

      api_response = ApiResponse.build(arrow.response)
      broadcast(arrow, api_response, query_params, body_params)
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

      {:arrow_exists, nil} ->
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

  defp broadcast(arrow, response, query_params, body_params) do
    Phoenix.PubSub.broadcast!(Redexor.PubSub, Redexor.RequestLogger.new_request_topic(), {:new_request, %{
      arrow: arrow,
      response: response,
      query_params: query_params,
      body_params: body_params
    }})
  end
end
