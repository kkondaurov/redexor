defmodule RestbenchWeb.MockServerLive.Show do
  use RestbenchWeb, :live_view

  alias Restbench.Accounts.User
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
  def handle_params(%{"id" => id}, _, socket) do
    user = socket.assigns[:user]

    case MockServers.get_mock_server(user, id) do
      %MockServer{} = mock_server ->
        {:noreply,
        socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:mock_server, mock_server)}

      nil ->
        socket = put_flash(socket, :error, "Mock Server not found")
        {:noreply, push_redirect(socket, to: "/mock_servers", replace: true)}
    end
  end

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

  defp page_title(:show), do: "Show Mock Server"
  defp page_title(:edit), do: "Edit Mock Server"
end
