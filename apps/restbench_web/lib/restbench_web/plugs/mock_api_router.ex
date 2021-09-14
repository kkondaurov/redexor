defmodule RestbenchWeb.Plugs.ApiRouter do
  require Logger

  import Plug.Conn

  alias Restbench.Api.Response
  alias Restbench.Api.Router

  def init(default), do: default

  def call(%Plug.Conn{path_info: [mock_server_id | path_parts], method: method} = conn, _default) do
    path = Enum.join(path_parts, "/")
    Logger.info(method: method, mock_server_id: mock_server_id, path: path, query_params: conn.query_params, body_params: conn.body_params)
    request_params = Map.merge(conn.query_params, conn.body_params)

    %Response{
      code: code,
      payload: payload
    } = Router.handle(mock_server_id, method, path, request_params)

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
