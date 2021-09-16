defmodule RestbenchWeb.LiveHelpers do
  @moduledoc false

  import Phoenix.LiveView.Helpers
  alias Restbench.Responses.Response

  @doc """
  Renders a component inside the `RestbenchWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal RestbenchWeb.ServerLive.FormComponent,
        id: @server.id || :new,
        action: @live_action,
        server: @server,
        return_to: Routes.server_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(RestbenchWeb.ModalComponent, modal_opts)
  end

  def api_host(), do: Application.get_env(:arrow_api, ArrowApi.Endpoint)[:url][:host]

  def format_response_body(%Response{} = response), do: Response.to_html(response)

  def mark_arrow_response(response_id, response_id), do: "default-response"
  def mark_arrow_response(_, _), do: ""
end
