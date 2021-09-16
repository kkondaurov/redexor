defmodule RestbenchWeb.ArrowLive.Show do
  @moduledoc false

  use RestbenchWeb, :live_view

  alias Restbench.Accounts.User
  alias Restbench.Arrows
  alias Restbench.Arrows.Arrow
  alias Restbench.Responses

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Restbench.Accounts.get_user_by_session_token(user_token)

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

  defp apply_action(socket, _action, _params), do: socket

  defp page_title(:show, %Arrow{title: title}), do: "#{title} - Routes"

end
