defmodule Restbench.ArrowApi.Router do
  @moduledoc """
  Context for Arrow API business logic.
  """

  require Logger

  alias Restbench.ArrowApi.Response
  alias Restbench.Arrows
  alias Restbench.Arrows.Arrow

  @spec handle(String.t(), String.t(), String.t(), map()) :: Response.t()
  def handle(server_id, method, path, _params) do
    with {:server_id_valid, {:ok, server_uuid}} <- {:server_id_valid, Ecto.UUID.cast(server_id)},
      {:arrow_exists, %Arrow{} = arrow} <- {:arrow_exists, Arrows.find_enabled_route(server_uuid, method, path)} do

      Logger.info(server_id: server_id, method: method, path: path, arrow: arrow)
      %Response{code: 200, payload: %{foo: "bar"}}
    else
      {:server_id_valid, _} ->
        Logger.warn(message: "Server id is invalid", error: 400, server_id: server_id, method: method, path: path)
        %Response{code: 400}

      {:arrow_exists, nil} ->
        Logger.warn(message: "Server or Route not found or disabled",  error: 404, server_id: server_id, method: method, path: path)
        %Response{code: 404}
    end
  end

end
