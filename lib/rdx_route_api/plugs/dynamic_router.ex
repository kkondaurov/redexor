defmodule RdxRouteApi.Plugs.DynamicRouter do
  @moduledoc """
  A plug for routing RdxRoute API requests.
  Deals with HTTP-level concerns,
  delegates business logic to RdxRouteApi.Router.
  """

  require Logger

  import Plug.Conn

  alias Redexor.RequestHandler
  alias Redexor.RequestHandler.ApiResponse

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

    %ApiResponse{
      code: code,
      payload: payload,
      latency: latency
    } = RequestHandler.handle(server_id, method, path, conn.query_params, conn.body_params)

    if latency > 0 do
      Logger.info(
        message: "Emulating response_template latency",
        method: method,
        server_id: server_id,
        path: path,
        latency: latency
      )

      Process.sleep(latency)
    end

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
