defmodule RedexorWeb.ServerLive.Show do
  @moduledoc false

  use RedexorWeb, :live_view

  alias Redexor.Accounts.User
  alias Redexor.RdxRoutes
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.Servers
  alias Redexor.Servers.Server

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Redexor.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _url, socket) do
    user = socket.assigns[:user]

    case Servers.get_server(user, id) do
      %Server{} = server ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action, server))
          |> assign(:server, server)
          |> assign(:rdx_routes, RdxRoutes.list_rdx_routes(user, server.id))
          |> assign(:id, server.id)
          |> apply_action(socket.assigns.live_action, params)

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Server not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp apply_action(socket, :edit_route, %{"rdx_route_id" => id} = _params) do
    user = socket.assigns[:user]

    case RdxRoutes.get_rdx_route(user, id) do
      %RdxRoute{} = rdx_route ->
        socket
        |> assign(:id, socket.assigns.server.id)
        |> assign(:rdx_route, rdx_route)

      nil ->
        socket
        |> put_flash(:error, "Route not found")
        |> push_redirect(to: "/servers", replace: true)
    end
  end

  defp apply_action(socket, :new_route, _params) do
    socket
    |> assign(:rdx_route, %RdxRoute{})
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case Servers.get_server(user, id) do
      %Server{} = server ->
        {:ok, server} = Servers.toggle_server(user, server)
        {:noreply, assign(socket, :server, server)}

      nil ->
        socket = put_flash(socket, :error, "Server not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("delete_route", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    server = socket.assigns[:server]

    case RdxRoutes.get_rdx_route(user, id) do
      %RdxRoute{} = rdx_route ->
        {:ok, _rdx_route} = RdxRoutes.delete_rdx_route(user, rdx_route)
        socket = assign(socket, :rdx_routes, RdxRoutes.list_rdx_routes(user, server.id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Route not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("toggle_route", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    server = socket.assigns[:server]

    case RdxRoutes.get_rdx_route(user, id) do
      %RdxRoute{} = rdx_route ->
        {:ok, _rdx_route} = RdxRoutes.toggle_rdx_route(user, rdx_route)
        socket = assign(socket, :rdx_routes, RdxRoutes.list_rdx_routes(user, server.id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Route not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp page_title(:show, server), do: "#{server.title} - Servers - redexor"
  defp page_title(:edit, server), do: "Edit #{server.title}"
  defp page_title(:new_route, _server), do: "New Route"
  defp page_title(:edit_route, _server), do: "Edit Route"
end
