defmodule RedexorWeb.RdxRouteLive.Log do
  @moduledoc false

  use RedexorWeb, :live_view

  alias Redexor.Accounts.User
  alias Redexor.RdxRoutes
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.RequestLog

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Redexor.Accounts.get_user_by_session_token(user_token)
    send(self(), :after_join)

    socket =
      socket
      |> assign(:user, user)
      |> assign_timezone()

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"rdx_route_id" => id} = _params, _url, socket) do
    user = socket.assigns[:user]

    case RdxRoutes.get_rdx_route(user, id) do
      %RdxRoute{} = rdx_route ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action, rdx_route))
          |> assign(:rdx_route, rdx_route)
          |> assign(:id, rdx_route.id)
          |> assign(:entries, RequestLog.list(rdx_route))

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Routes not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp page_title(:index, %RdxRoute{title: title}), do: "#{title} - Request Log - redexor"

  defp assign_timezone(socket) do
    socket
    |> assign(:timezone, get_connect_params(socket)["timezone"])
    |> assign(:timezone_offset, get_connect_params(socket)["timezone_offset"])
  end

  @impl true
  def handle_info(:after_join, socket) do
    topic = Redexor.RequestLogger.logged_request_topic(socket.assigns.rdx_route.id)
    Phoenix.PubSub.subscribe(Redexor.PubSub, topic)
    {:noreply, socket}
  end

  def handle_info({:logged_request, entry}, %{assigns: %{entries: entries}} = socket) do
    {:noreply, assign(socket, entries: [entry | entries])}
  end
end
