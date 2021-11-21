defmodule RedexorWeb.RdxRouteLive.FormComponent do
  @moduledoc false

  use RedexorWeb, :live_component
  require Logger
  alias Redexor.RdxRoutes

  @impl true
  def update(%{server: server, user: user, rdx_route: rdx_route} = assigns, socket) do
    changeset =
      rdx_route
      |> Map.put(:server_id, server.id)
      |> Map.put(:user_id, user.id)
      |> RdxRoutes.change_rdx_route()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:methods, RdxRoutes.RdxRoute.allowed_methods())
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"rdx_route" => rdx_route_params}, socket) do
    changeset =
      socket.assigns.rdx_route
      |> RdxRoutes.change_rdx_route(rdx_route_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"rdx_route" => rdx_route_params}, socket) do
    save_rdx_route(socket, socket.assigns.action, rdx_route_params)
  end

  defp save_rdx_route(socket, :edit_route, rdx_route_params) do
    user = socket.assigns[:user]

    case RdxRoutes.update_rdx_route(user, socket.assigns.rdx_route, rdx_route_params) do
      {:ok, _rdx_route} ->
        {:noreply,
         socket
         |> put_flash(:info, "Route updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_rdx_route(socket, :new_route, rdx_route_params) do
    user = socket.assigns[:user]
    server = socket.assigns[:server]

    case RdxRoutes.create_rdx_route(user, server, rdx_route_params) do
      {:ok, _rdx_route} ->
        {:noreply,
         socket
         |> put_flash(:info, "Route created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
