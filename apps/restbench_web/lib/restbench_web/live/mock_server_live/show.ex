defmodule RestbenchWeb.MockServerLive.Show do
  @moduledoc false

  use RestbenchWeb, :live_view

  alias Restbench.Accounts.User
  alias Restbench.MockRoutes
  alias Restbench.MockRoutes.MockRoute
  alias Restbench.MockServers
  alias Restbench.MockServers.MockServer

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Restbench.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    user = socket.assigns[:user]

    case MockServers.get_mock_server(user, id) do
      %MockServer{} = mock_server ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action))
          |> assign(:mock_server, mock_server)
          |> assign(:mock_routes, MockRoutes.list_mock_routes(user, mock_server.id))
          |> assign(:id, mock_server.id)
          |> apply_action(socket.assigns.live_action, params)

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Mock Server not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  defp apply_action(socket, :edit_route, %{"mock_route_id" => id} = _params) do
    user = socket.assigns[:user]

    case MockRoutes.get_mock_route(user, id) do
      %MockRoute{} = mock_route ->
        socket
        |> assign(:id, socket.assigns.mock_server.id)
        |> assign(:mock_route, mock_route)

      nil ->
        socket = put_flash(socket, :error, "Mock Route not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  defp apply_action(socket, :new_route, _params) do
    socket
    |> assign(:mock_route, %MockRoute{})
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case MockServers.get_mock_server(user, id) do
      %MockServer{} = mock_server ->
        {:ok, mock_server} = MockServers.toggle_mock_server(user, mock_server)
        {:noreply, assign(socket, :mock_server, mock_server)}

      nil ->
        socket = put_flash(socket, :error, "Mock Server not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  def handle_event("delete_route", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    mock_server = socket.assigns[:mock_server]

    case MockRoutes.get_mock_route(user, id) do
      %MockRoute{} = mock_route ->
        {:ok, _mock_route} = MockRoutes.delete_mock_route(user, mock_route)
        socket = assign(socket, :mock_routes, MockRoutes.list_mock_routes(user, mock_server.id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Mock Route not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  def handle_event("toggle_route", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    mock_server = socket.assigns[:mock_server]

    case MockRoutes.get_mock_route(user, id) do
      %MockRoute{} = mock_route ->
        {:ok, _mock_route} = MockRoutes.toggle_mock_route(user, mock_route)
        socket = assign(socket, :mock_routes, MockRoutes.list_mock_routes(user, mock_server.id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Mock Route not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

  defp page_title(:show), do: "Show Mock Server"
  defp page_title(:edit), do: "Edit Mock Server"
  defp page_title(:new_route), do: "New Mock Route"
  defp page_title(:edit_route), do: "Edit Mock Route"
end
