defmodule RestbenchWeb.MockServerLive.FormComponent do
  use RestbenchWeb, :live_component

  alias Restbench.MockServers

  @impl true
  def update(%{mock_server: mock_server} = assigns, socket) do
    changeset = MockServers.change_mock_server(mock_server)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"mock_server" => mock_server_params}, socket) do
    changeset =
      socket.assigns.mock_server
      |> MockServers.change_mock_server(mock_server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"mock_server" => mock_server_params}, socket) do
    save_mock_server(socket, socket.assigns.action, mock_server_params)
  end

  defp save_mock_server(socket, :edit, mock_server_params) do
    case MockServers.update_mock_server(socket.assigns.mock_server, mock_server_params) do
      {:ok, _mock_server} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mock server updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_mock_server(socket, :new, mock_server_params) do
    case MockServers.create_mock_server(mock_server_params) do
      {:ok, _mock_server} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mock server created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
