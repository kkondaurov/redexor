defmodule RestbenchWeb.MockServerLive.Show do
  use RestbenchWeb, :live_view

  alias Restbench.MockServers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:mock_server, MockServers.get_mock_server!(id))}
  end

  defp page_title(:show), do: "Show Mock Server"
  defp page_title(:edit), do: "Edit Mock Server"
end
