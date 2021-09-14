defmodule Restbench.ArrowApiRouterTest do
  use Restbench.DataCase

  alias Restbench.Arrows
  alias Restbench.ArrowApi.Router
  alias Restbench.ArrowApi.Response
  alias Restbench.Servers
  alias Restbench.Support.AccountsFixtures
  alias Restbench.Support.ArrowsFixtures
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

  describe "ApiRouter" do

    test "handle/4 with enabled server, method and path", %{server: server, arrow: arrow} do
      assert %Response{code: 200} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 with enabled server, but method and path of a disabled arrow", %{user: user, server: server, arrow: arrow} do
      {:ok, arrow} = Arrows.update_arrow(user, arrow, %{enabled: false})
      assert %Response{code: 404} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 with enabled server, but non-existent path and method", %{server: server} do
      assert %Response{code: 404} = Router.handle(server.id, "GET", "/whatever", %{})
    end

    test "handle/4 with disabled server, and existing method and path", %{user: user, server: server, arrow: arrow} do
      {:ok, server} = Servers.update_server(user, server, %{enabled: false})
      assert %Response{code: 404} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 with non-existent server", %{arrow: arrow} do
      fake_server_id = Ecto.UUID.autogenerate()
      assert %Response{code: 404} = Router.handle(fake_server_id, arrow.method, arrow.path, %{})
    end
  end
end
