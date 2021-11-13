defmodule Redexor.RequestLoggerTest do
  use Redexor.DataCase

  alias Redexor.RequestHandler
  alias Redexor.RequestLog
  alias Redexor.RequestLog.RequestLogEntry
  alias Redexor.Support.{AccountsFixtures, RdxRoutesFixtures, ServersFixtures}

  require Logger

  @valid_attrs %{
    method: "GET",
    path: "/some/path",
    title: "Some title"
  }

  setup do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    rdx_route = RdxRoutesFixtures.rdx_route_fixture(user, server, @valid_attrs)

    GenServer.start_link(Redexor.RequestLogger, [], name: Redexor.TestRequestLogger)

    {:ok, rdx_route: rdx_route, user: user, server: server}
  end

  test "logs a successful request and broadcasts new log record", %{server: server, rdx_route: %{id: rdx_route_id} = rdx_route} do
    Phoenix.PubSub.subscribe(Redexor.PubSub, logged_request_topic(rdx_route_id))

    RequestHandler.handle(server.id, rdx_route.method, rdx_route.path, %{}, %{})

    assert_receive {:logged_request, %RequestLogEntry{} = log_entry}
    assert %RequestLogEntry{
      response_code: 200,
      rdx_route_id: ^rdx_route_id
    } = log_entry

    assert [log_entry] = RequestLog.list(rdx_route)
    assert %RequestLogEntry{
      response_code: 200,
      rdx_route_id: ^rdx_route_id
    } = log_entry
  end

  defp logged_request_topic(rdx_route_id), do: "logged_api_request:#{rdx_route_id}"

end
