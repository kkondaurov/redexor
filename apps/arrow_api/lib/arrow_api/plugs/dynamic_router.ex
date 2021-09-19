defmodule ArrowApi.Plugs.DynamicRouter do
  @moduledoc """
  A plug for routing Arrow API requests.
  Deals with HTTP-level concerns,
  delegates business logic to ArrowApi.Router.
  """

  require Logger

  import Plug.Conn

  alias Redexor.ArrowApi.ApiResponse
  alias Redexor.ArrowApi.Router

  def init(default), do: default

  def call(%Plug.Conn{host: host, path_info: path_parts, method: method} = conn, _default) do
    [server_id | _] = String.split(host, ".")
    path = "/" <> Enum.join(path_parts, "/")

    Logger.info(
      message: "Routing API request",
      method: method,
      server_id: server_id,
      path: path,
      query_params: conn.query_params,
      body_params: conn.body_params
    )

    request_params = Map.merge(conn.query_params, conn.body_params)

    %ApiResponse{
      code: code,
      payload: payload
    } = Router.handle(server_id, method, path, request_params)

    conn
    |> put_status(code)
    |> Phoenix.Controller.json(payload)
  end

  def call(%Plug.Conn{} = conn, _default) do
    Logger.warn(%{conn: conn})
    conn
    |> send_resp(400, "Bad request")
    |> halt()
  end
end
