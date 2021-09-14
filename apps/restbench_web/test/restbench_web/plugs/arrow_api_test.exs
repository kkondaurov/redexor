defmodule RestbenchWeb.ArrowApiTest do
  use RestbenchWeb.ConnCase

  alias Restbench.Support.ArrowsFixtures
  alias Restbench.Support.AccountsFixtures
  alias Restbench.Support.ServersFixtures

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

  describe "/api" do

    test "GET /api", %{conn: conn} do
      resp = get(conn, "/api")
      assert resp.status == 400
    end

    test "GET /api for existing path of existing server", %{conn: conn, server: server, arrow: arrow} do
      resp = get(conn, "/api/#{server.id}#{arrow.path}")
      assert resp.status == 200
    end
  end

end
