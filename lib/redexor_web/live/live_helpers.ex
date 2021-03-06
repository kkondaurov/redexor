defmodule RedexorWeb.LiveHelpers do
  @moduledoc false

  import Phoenix.LiveView.Helpers
  alias Redexor.ResponseTemplates.ResponseTemplate

  @doc """
  Renders a component inside the `RedexorWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal RedexorWeb.ServerLive.FormComponent,
        id: @server.id || :new,
        action: @live_action,
        server: @server,
        return_to: Routes.server_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(RedexorWeb.ModalComponent, modal_opts)
  end

  def api_host, do: Application.get_env(:redexor, RdxRouteApi.Endpoint)[:url][:host]

  def format_response_body(%ResponseTemplate{} = response_template),
    do: ResponseTemplate.to_html(response_template)

  def mark_rdx_route_response(%ResponseTemplate{id: response_id}, response_id),
    do: "default-response_template"

  def mark_rdx_route_response(_, _), do: ""

  def format_datetime(utc_datetime, opts),
    do: RedexorWeb.LayoutView.format_datetime(utc_datetime, opts)
end
