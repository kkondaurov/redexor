defmodule RedexorWeb.ArrowLive.Log do
  @moduledoc false

  use RedexorWeb, :live_view

  alias Redexor.Accounts.User
  alias Redexor.Arrows
  alias Redexor.Arrows.Arrow
  alias Redexor.RequestLog

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Redexor.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:user, user)
      |> assign_timezone()

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"arrow_id" => id} = _params, _url, socket) do
    user = socket.assigns[:user]

    case Arrows.get_arrow(user, id) do
      %Arrow{} = arrow ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action, arrow))
          |> assign(:arrow, arrow)
          |> assign(:id, arrow.id)
          |> assign(:entries, RequestLog.list(arrow))

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Routes not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp page_title(:index, %Arrow{title: title}), do: "#{title} - Request Log - redexor"

  defp assign_timezone(socket) do
    socket
    |> assign(:timezone, get_connect_params(socket)["timezone"])
    |> assign(:timezone_offset, get_connect_params(socket)["timezone_offset"])
  end

end
