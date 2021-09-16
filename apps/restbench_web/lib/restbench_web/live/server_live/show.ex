defmodule RestbenchWeb.ServerLive.Show do
  @moduledoc false

  use RestbenchWeb, :live_view

  alias Restbench.Accounts.User
  alias Restbench.Arrows
  alias Restbench.Arrows.Arrow
  alias Restbench.Servers
  alias Restbench.Servers.Server

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

    case Servers.get_server(user, id) do
      %Server{} = server ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action, server))
          |> assign(:server, server)
          |> assign(:arrows, Arrows.list_arrows(user, server.id))
          |> assign(:id, server.id)
          |> apply_action(socket.assigns.live_action, params)

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Server not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp apply_action(socket, :edit_route, %{"arrow_id" => id} = _params) do
    user = socket.assigns[:user]

    case Arrows.get_arrow(user, id) do
      %Arrow{} = arrow ->
        socket
        |> assign(:id, socket.assigns.server.id)
        |> assign(:arrow, arrow)

      nil ->
        socket
        |> put_flash(:error, "Route not found")
        |> push_redirect(to: "/servers", replace: true)
    end
  end

  defp apply_action(socket, :new_route, _params) do
    socket
    |> assign(:arrow, %Arrow{})
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

    case Arrows.get_arrow(user, id) do
      %Arrow{} = arrow ->
        {:ok, _arrow} = Arrows.delete_arrow(user, arrow)
        socket = assign(socket, :arrows, Arrows.list_arrows(user, server.id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Route not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("toggle_route", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    server = socket.assigns[:server]

    case Arrows.get_arrow(user, id) do
      %Arrow{} = arrow ->
        {:ok, _arrow} = Arrows.toggle_arrow(user, arrow)
        socket = assign(socket, :arrows, Arrows.list_arrows(user, server.id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Route not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp page_title(:show, server), do: "#{server.title} - Servers - restbench"
  defp page_title(:edit, server), do: "Edit #{server.title}"
  defp page_title(:new_route, _server), do: "New Route"
  defp page_title(:edit_route, _server), do: "Edit Route"
end
