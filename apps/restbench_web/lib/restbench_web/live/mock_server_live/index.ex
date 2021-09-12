defmodule RestbenchWeb.MockServerLive.Index do
  use RestbenchWeb, :live_view

  alias Restbench.MockServers
  alias Restbench.MockServers.MockServer
  alias Restbench.Accounts.User

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Restbench.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:mock_servers, list_mock_servers(user))
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = socket.assigns[:user]
    case MockServers.get_mock_server(user, id) do
      %MockServer{} = mock_server ->
        socket
        |> assign(:page_title, "Edit Mock Server")
        |> assign(:mock_server, mock_server)
      nil ->
        socket = put_flash(socket, :error, "Mock Server not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
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
    user = socket.assigns[:user]

    case MockServers.get_mock_server(user, id) do
      %MockServer{} = mock_server ->
        {:ok, _} = MockServers.delete_mock_server(user, mock_server)
        {:noreply, assign(socket, :mock_servers, list_mock_servers(user))}

      nil ->
        socket = put_flash(socket, :error, "Mock Server not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case MockServers.get_mock_server(user, id) do
      %MockServer{} = mock_server ->
        {:ok, _} = MockServers.toggle_mock_server(user, mock_server)
        {:noreply, assign(socket, :mock_servers, list_mock_servers(user))}

      nil ->
        socket = put_flash(socket, :error, "Mock Server not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  defp list_mock_servers(user) do
    MockServers.list_mock_servers(user)
  end
end
