defmodule RedexorWeb.ArrowLive.Show do
  @moduledoc false

  use RedexorWeb, :live_view

  alias Redexor.Accounts.User
  alias Redexor.Arrows
  alias Redexor.Arrows.Arrow
  alias Redexor.Responses
  alias Redexor.Responses.Response

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Redexor.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"arrow_id" => id} = params, _url, socket) do
    user = socket.assigns[:user]

    case Arrows.get_arrow(user, id) do
      %Arrow{} = arrow ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action, arrow))
          |> assign(:arrow, arrow)
          |> assign(:id, arrow.id)
          |> assign(:responses, Responses.list_responses(user, arrow.id))
          |> apply_action(socket.assigns.live_action, params)

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Routes not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp apply_action(socket, :edit_response, %{"response_id" => id} = _params) do
    user = socket.assigns[:user]

    case Responses.get_response(user, id) do
      %Response{} = response ->
        socket
        |> assign(:arrow_id, socket.assigns.arrow.id)
        |> assign(:response, response)

      nil ->
        socket
        |> put_flash(:error, "Route not found")
        |> push_redirect(to: "/servers", replace: true)
    end
  end

  defp apply_action(socket, :new_response, _params) do
    socket
    |> assign(:response, %Response{})
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case Arrows.get_arrow(user, id) do
      %Arrow{} = arrow ->
        {:ok, arrow} = Arrows.toggle_arrow(user, arrow)
        {:noreply, assign(socket, :arrow, arrow)}

      nil ->
        socket = put_flash(socket, :error, "Route not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("delete_response", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case Responses.get_response(user, id) do
      %Response{} = response ->
        {:ok, _response} = Responses.delete_response(user, response)
        socket = assign(socket, :responses, Responses.list_responses(user, response.arrow_id))
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Response not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("activate_response", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    arrow = socket.assigns[:arrow]

    case Responses.get_response(user, id) do
      %Response{} = response ->
        {:ok, arrow} = Arrows.update_arrow(user, arrow, %{response_id: id})
        socket =
          socket
          |> assign(:responses, Responses.list_responses(user, response.arrow_id))
          |> assign(:arrow, arrow)
        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Response not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp page_title(:show, %Arrow{title: title}), do: "#{title} - Routes - redexor"
  defp page_title(:new_response, _), do: "New Response"
  defp page_title(:edit_response, _), do: "Edit Response"

end
