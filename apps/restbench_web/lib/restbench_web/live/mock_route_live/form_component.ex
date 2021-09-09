defmodule RestbenchWeb.MockRouteLive.FormComponent do
  use RestbenchWeb, :live_component

  alias Restbench.MockRoutes

  @impl true
  def update(%{mock_server: mock_server, user: user, mock_route: mock_route} = assigns, socket) do
    changeset =
      mock_route
      |> Map.put(:mock_server_id, mock_server.id)
      |> Map.put(:user_id, user.id)
      |> MockRoutes.change_mock_route()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"mock_route" => mock_route_params}, socket) do
    changeset =
      socket.assigns.mock_route
      |> MockRoutes.change_mock_route(mock_route_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"mock_route" => mock_route_params}, socket) do
    save_mock_route(socket, socket.assigns.action, mock_route_params)
  end

  defp save_mock_route(socket, :edit_route, mock_route_params) do
    user = socket.assigns[:user]
    case MockRoutes.update_mock_route(user, socket.assigns.mock_route, mock_route_params) do
      {:ok, _mock_route} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mock Route updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_mock_route(socket, :new_route, mock_route_params) do
    user = socket.assigns[:user]
    mock_server = socket.assigns[:mock_server]
    case MockRoutes.create_mock_route(user, mock_server, mock_route_params) do
      {:ok, _mock_route} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mock Route created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
