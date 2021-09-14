defmodule RestbenchWeb.Plugs.ArrowApi do
  @moduledoc """
  A plug for routing Arrow API requests.
  Deals with HTTP-level concerns,
  delegates business logic to ArrowApi.Router.
  """

  require Logger

  import Plug.Conn

  alias Restbench.ArrowApi.Response
  alias Restbench.ArrowApi.Router

  def init(default), do: default

  def call(%Plug.Conn{path_info: [server_id | path_parts], method: method} = conn, _default) do
    path = "/" <> Enum.join(path_parts, "/")
    Logger.info(message: "Routing API request", method: method, server_id: server_id, path: path, query_params: conn.query_params, body_params: conn.body_params)
    request_params = Map.merge(conn.query_params, conn.body_params)

    %Response{
      code: code,
      payload: payload
    } = Router.handle(server_id, method, path, request_params)

    conn
    |> put_status(code)
    |> Phoenix.Controller.json(payload)
  end

  def call(%Plug.Conn{} = conn, _default) do
    conn
    |> send_resp(400, "Bad request")
    |> halt()
  end
end
