defmodule RestbenchWeb.ArrowLive.FormComponent do
  @moduledoc false

  use RestbenchWeb, :live_component

  alias Restbench.Arrows

  @impl true
  def update(%{server: server, user: user, arrow: arrow} = assigns, socket) do
    changeset =
      arrow
      |> Map.put(:server_id, server.id)
      |> Map.put(:user_id, user.id)
      |> Arrows.change_arrow()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"arrow" => arrow_params}, socket) do
    changeset =
      socket.assigns.arrow
      |> Arrows.change_arrow(arrow_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"arrow" => arrow_params}, socket) do
    save_arrow(socket, socket.assigns.action, arrow_params)
  end

  defp save_arrow(socket, :edit_route, arrow_params) do
    user = socket.assigns[:user]

    case Arrows.update_arrow(user, socket.assigns.arrow, arrow_params) do
      {:ok, _arrow} ->
        {:noreply,
         socket
         |> put_flash(:info, "Route updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_arrow(socket, :new_route, arrow_params) do
    user = socket.assigns[:user]
    server = socket.assigns[:server]

    case Arrows.create_arrow(user, server, arrow_params) do
      {:ok, _arrow} ->
        {:noreply,
         socket
         |> put_flash(:info, "Route created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
