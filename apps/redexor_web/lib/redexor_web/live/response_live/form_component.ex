defmodule RedexorWeb.ResponseLive.FormComponent do
  @moduledoc false

  use RedexorWeb, :live_component
  require Logger
  alias Redexor.Arrows
  alias Redexor.Responses

  @impl true
  def update(%{arrow: arrow, response: response} = assigns, socket) do
    changeset =
      response
      |> Map.put(:arrow_id, arrow.id)
      |> Responses.change_response()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"response" => response_params}, socket) do
    changeset =
      socket.assigns.response
      |> Responses.change_response(response_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"response" => response_params}, socket) do
    save_response(socket, socket.assigns.action, response_params)
  end

  defp save_response(socket, :edit_response, response_params) do
    user = socket.assigns[:user]

    case Responses.update_response(user, socket.assigns.response, response_params) do
      {:ok, _response} ->
        {:noreply,
         socket
         |> put_flash(:info, "Response updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_response(socket, :new_response, response_params) do
    user = socket.assigns[:user]
    arrow = socket.assigns[:arrow]

    case Responses.create_response(user, arrow, response_params) do
      {:ok, response} ->
        {:ok, _arrow} = Arrows.maybe_set_response(user, arrow, response.id)
        {:noreply,
         socket
         |> put_flash(:info, "Response created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
