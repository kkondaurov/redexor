defmodule Redexor.RequestLogger do
  use GenServer
  require Logger
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.RequestLog
  alias Redexor.RequestLog.RequestLogEntry

  @name :api_request_logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  def logged_request_topic(rdx_route_id), do: "logged_api_request:#{rdx_route_id}"

  def new_request_topic(), do: "new_api_request"

  @impl true
  def init(state) do
    Phoenix.PubSub.subscribe(Redexor.PubSub, new_request_topic())
    {:ok, state}
  end

  @impl true
  def handle_info({:new_request, payload}, state) do
    record_request!(payload)
    {:noreply, state}
  end

  defp record_request!(payload) do
    %{
      rdx_route: %RdxRoute{} = rdx_route,
      response_template: response_template,
      query_params: query_params,
      body_params: body_params
    } = payload

    %RequestLogEntry{} =
      entry = RequestLog.log!(rdx_route, response_template, query_params, body_params)

    topic = logged_request_topic(rdx_route.id)
    Logger.info(message: "Logged request", entry: entry)

    Phoenix.PubSub.broadcast!(Redexor.PubSub, topic, {:logged_request, entry})
  end
end
