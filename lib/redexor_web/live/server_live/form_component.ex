defmodule RedexorWeb.ServerLive.FormComponent do
  @moduledoc false

  use RedexorWeb, :live_component
  require Logger
  alias Redexor.Servers

  @impl true
  def update(%{server: server, user: user} = assigns, socket) do
    changeset =
      server
      |> Map.put(:user_id, user.id)
      |> Servers.change_server()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      socket.assigns.server
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    save_server(socket, socket.assigns.action, server_params)
  end

  defp save_server(socket, :edit, server_params) do
    user = socket.assigns[:user]
    server = socket.assigns[:server]

    case Servers.update_server(user, server, server_params) do
      {:ok, _server} ->
        {:noreply,
         socket
         |> put_flash(:info, "Server updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_server(socket, :new, server_params) do
    user = socket.assigns[:user]

    case Servers.create_server(user, server_params) do
      {:ok, _server} ->
        {:noreply,
         socket
         |> put_flash(:info, "Server created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
