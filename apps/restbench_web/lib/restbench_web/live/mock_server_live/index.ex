defmodule RestbenchWeb.MockServerLive.Index do
  use RestbenchWeb, :live_view

  alias Restbench.MockServers
  alias Restbench.MockServers.MockServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :mock_servers, list_mock_servers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Mock Server")
    |> assign(:mock_server, MockServers.get_mock_server!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Mock Server")
    |> assign(:mock_server, %MockServer{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Mock Servers")
    |> assign(:mock_server, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mock_server = MockServers.get_mock_server!(id)
    {:ok, _} = MockServers.delete_mock_server(mock_server)

    {:noreply, assign(socket, :mock_servers, list_mock_servers())}
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    mock_server = MockServers.get_mock_server!(id)
    {:ok, _} = MockServers.toggle_mock_server(mock_server)

    {:noreply, assign(socket, :mock_servers, list_mock_servers())}
  end

  defp list_mock_servers do
    MockServers.list_mock_servers()
  end
end
