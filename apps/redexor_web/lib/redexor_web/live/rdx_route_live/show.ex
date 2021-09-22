defmodule RedexorWeb.RdxRouteLive.Show do
  @moduledoc false

  use RedexorWeb, :live_view

  alias Redexor.Accounts.User
  alias Redexor.RdxRoutes
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.ResponseTemplates
  alias Redexor.ResponseTemplates.ResponseTemplate

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    %User{} = user = Redexor.Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"rdx_route_id" => id} = params, _url, socket) do
    user = socket.assigns[:user]

    case RdxRoutes.get_rdx_route(user, id) do
      %RdxRoute{} = rdx_route ->
        socket =
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action, rdx_route))
          |> assign(:rdx_route, rdx_route)
          |> assign(:id, rdx_route.id)
          |> assign(:response_templates, ResponseTemplates.list_responses(user, rdx_route.id))
          |> apply_action(socket.assigns.live_action, params)

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Routes not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp apply_action(socket, :edit_response, %{"response_id" => id} = _params) do
    user = socket.assigns[:user]

    case ResponseTemplates.get_response(user, id) do
      %ResponseTemplate{} = response_template ->
        socket
        |> assign(:rdx_route_id, socket.assigns.rdx_route.id)
        |> assign(:response_template, response_template)

      nil ->
        socket
        |> put_flash(:error, "Route not found")
        |> push_redirect(to: "/servers", replace: true)
    end
  end

  defp apply_action(socket, :new_response, _params) do
    socket
    |> assign(:response_template, %ResponseTemplate{})
  end

  defp apply_action(socket, _action, _params), do: socket

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case RdxRoutes.get_rdx_route(user, id) do
      %RdxRoute{} = rdx_route ->
        {:ok, rdx_route} = RdxRoutes.toggle_rdx_route(user, rdx_route)
        {:noreply, assign(socket, :rdx_route, rdx_route)}

      nil ->
        socket = put_flash(socket, :error, "Route not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("delete_response", %{"id" => id}, socket) do
    user = socket.assigns[:user]

    case ResponseTemplates.get_response(user, id) do
      %ResponseTemplate{} = response_template ->
        {:ok, _response} = ResponseTemplates.delete_response(user, response_template)

        socket =
          assign(
            socket,
            :response_templates,
            ResponseTemplates.list_responses(user, response_template.rdx_route_id)
          )

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Response Template not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  def handle_event("select_response", %{"id" => id}, socket) do
    user = socket.assigns[:user]
    rdx_route = socket.assigns[:rdx_route]

    case ResponseTemplates.get_response(user, id) do
      %ResponseTemplate{} = response_template ->
        {:ok, _response} = ResponseTemplates.set_selected(user, response_template)

        socket =
          socket
          |> assign(
            :response_templates,
            ResponseTemplates.list_responses(user, response_template.rdx_route_id)
          )
          |> assign(:rdx_route, RdxRoutes.get_rdx_route(user, rdx_route.id))

        {:noreply, socket}

      nil ->
        socket = put_flash(socket, :error, "Response Template not found")
        {:noreply, push_redirect(socket, to: "/servers", replace: true)}
    end
  end

  defp page_title(:show, %RdxRoute{title: title}), do: "#{title} - Routes - redexor"
  defp page_title(:new_response, _), do: "New Response Template"
  defp page_title(:edit_response, _), do: "Edit Response Template"
end
