defmodule ArrowApi.DynamicRouterTest do
  use ArrowApi.ConnCase

  alias Restbench.Support.ArrowsFixtures
  alias Restbench.Support.AccountsFixtures
  alias Restbench.Support.ServersFixtures

  require Logger

  @valid_attrs %{
    method: "GET",
    path: "/some/path",
    title: "Some title"
  }

  setup do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    arrow = ArrowsFixtures.arrow_fixture(user, server, @valid_attrs)
    {:ok, arrow: arrow, user: user, server: server}
  end

  describe "/" do

    test "GET / for existing path of existing server", %{server: server, arrow: arrow} do
      conn = build_conn_to_server(:get, server.id)
      resp = get(conn, "#{arrow.path}")
      assert resp.status == 200
    end

    test "GET / for existing path of non-existent server", %{arrow: arrow} do
      fake_server_id = "8163b9e1-99b4-43d9-8938-108b4cc65d24"
      conn = build_conn_to_server(:get, fake_server_id)
      resp = get(conn, "#{arrow.path}")
      assert resp.status == 404
    end
  end

  defp build_conn_to_server(method, server_id) do
    host = "#{server_id}." <> ArrowApi.Endpoint.config(:url)[:host]
    Phoenix.ConnTest.build_conn(method, "http://#{host}/", nil)
  end
end
