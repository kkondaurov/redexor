defmodule Redexor.ArrowApi.Router do
  @moduledoc """
  Context for Arrow API business logic.
  """

  require Logger

  alias Redexor.ArrowApi.ApiResponse
  alias Redexor.Arrows
  alias Redexor.Arrows.Arrow
  alias Redexor.RequestLog

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

      arrow.response
      |> ApiResponse.build()
      |> tap(&(RequestLog.log(arrow, &1, query_params, body_params)))
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
end
