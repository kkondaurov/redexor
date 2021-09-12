defmodule Restbench.MockApi.Router do

  require Logger

  alias Restbench.MockApi.Response
  alias Restbench.MockRoutes
  alias Restbench.MockRoutes.MockRoute

  @spec handle(String.t(), String.t(), String.t(), map()) :: Response.t()
  def handle(mock_server_id, method, path, _params) do
    with {:mock_server_id_valid, {:ok, mock_server_uuid}} <- {:mock_server_id_valid, Ecto.UUID.cast(mock_server_id)},
      {:mock_route_exists, %MockRoute{} = mock_route} <- {:mock_route_exists, MockRoutes.find_enabled_route(mock_server_uuid, method, path)} do

      Logger.info(mock_server_id: mock_server_id, method: method, path: path, mock_route: mock_route)
      %Response{code: 200, payload: %{foo: "bar"}}
    else
      {:mock_server_id_valid, _} ->
        Logger.warn(message: "Mock Server id is invalid", error: 400, mock_server_id: mock_server_id, method: method, path: path)
        %Response{code: 400}

      {:mock_route_exists, nil} ->
        Logger.warn(message: "Mock Server or Route not found or disabled",  error: 404, mock_server_id: mock_server_id, method: method, path: path)
        %Response{code: 404}
    end
  end

end
