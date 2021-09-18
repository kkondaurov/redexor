defmodule RedexorWeb.ServerLive.Index do
  @moduledoc false

  use RedexorWeb, :live_view

  alias Redexor.Accounts.User
  alias Redexor.Servers
  alias Redexor.Servers.Server

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Redexor.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:servers, list_servers(user))
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = socket.assigns[:user]

    case Servers.get_server(user, id) do
      %Server{} = server ->
        socket
        |> assign(:page_title, "Edit #{server.title}")
        |> assign(:server, server)

      nil ->
        socket = put_flash(socket, :error, "Server not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Server - redexor")
    |> assign(:server, %Server{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Servers - redexor")
    |> assign(:server, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case Servers.get_server(user, id) do
      %Server{} = server ->
        {:ok, _} = Servers.delete_server(user, server)
        {:noreply, assign(socket, :servers, list_servers(user))}

      nil ->
        socket = put_flash(socket, :error, "Server not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case Servers.get_server(user, id) do
      %Server{} = server ->
        {:ok, _} = Servers.toggle_server(user, server)
        {:noreply, assign(socket, :servers, list_servers(user))}

      nil ->
        socket = put_flash(socket, :error, "Server not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp list_servers(user) do
    Servers.list_servers(user)
  end
end
