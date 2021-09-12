defmodule RestbenchWeb.ModalComponent do
  @moduledoc false

  use RestbenchWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="phx-modal card mb-4"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={@myself}
      phx-page-loading>

      <div class="phx-modal-content card-content">
        <%= live_patch to: @return_to, class: "button is-small is-danger has-icons-left has-text-light" do %>
        <span class="icon is-small">
          <i class="fas fa-times"></i>
        </span>
        <% end %>
        <%= live_component @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
