defmodule RedexorWeb.ResponseLive.FormComponent do
  @moduledoc false

  use RedexorWeb, :live_component
  require Logger
  alias Redexor.ResponseTemplates

  @impl true
  def update(%{rdx_route: rdx_route, response_template: response_template} = assigns, socket) do
    changeset =
      response_template
      |> Map.put(:rdx_route_id, rdx_route.id)
      |> ResponseTemplates.change_response()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:types, ResponseTemplates.ResponseTemplate.implemented_types())
     |> assign(:latencies, ResponseTemplates.ResponseTemplate.allowed_latencies())
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"response_template" => response_params}, socket) do
    changeset =
      socket.assigns.response_template
      |> ResponseTemplates.change_response(response_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"response_template" => response_params}, socket) do
    save_response(socket, socket.assigns.action, response_params)
  end

  defp save_response(socket, :edit_response, response_params) do
    user = socket.assigns[:user]

    case ResponseTemplates.update_response(
           user,
           socket.assigns.response_template,
           response_params
         ) do
      {:ok, _response} ->
        {:noreply,
         socket
         |> put_flash(:info, "Response Template updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_response(socket, :new_response, response_params) do
    user = socket.assigns[:user]
    rdx_route = socket.assigns[:rdx_route]

    case ResponseTemplates.create_response(user, rdx_route, response_params) do
      {:ok, _response} ->
        {:noreply,
         socket
         |> put_flash(:info, "Response Template created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
