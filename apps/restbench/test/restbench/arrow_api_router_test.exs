defmodule Restbench.ArrowApiRouterTest do
  use Restbench.DataCase

  alias Restbench.Arrows
  alias Restbench.ArrowApi.Router
  alias Restbench.ArrowApi.Response
  alias Restbench.Servers
  alias Restbench.Support.AccountsFixtures
  alias Restbench.Support.ArrowsFixtures
  alias Restbench.Support.ServersFixtures
  alias Restbench.Responses

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

  describe "Test servers, methods and paths" do

    test "handle/4 returns empty response given enabled server and route without a configured response", %{server: server, arrow: arrow} do
      assert %Response{code: 200, payload: %{}} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 returns configured text response", %{server: server, user: user, arrow: arrow} do
      {:ok, response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "hello world!",
        title: "response title"
      })
      {:ok, arrow} = Arrows.maybe_set_response(user, arrow, response.id)
      assert %Response{code: 403, payload: "hello world!"} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 returns configured json response", %{server: server, user: user, arrow: arrow} do
      {:ok, response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "JSON",
        json_body: "{\"foo\":\"bar\"}",
        title: "response title"
      })
      {:ok, arrow} = Arrows.maybe_set_response(user, arrow, response.id)
      assert %Response{code: 403, payload:  %{"foo" => "bar"}} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 returns error givem enabled server, but method and path of a disabled arrow", %{user: user, server: server, arrow: arrow} do
      {:ok, arrow} = Arrows.update_arrow(user, arrow, %{enabled: false})
      assert %Response{code: 404} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 returns error given enabled server, but non-existent path and method", %{server: server} do
      assert %Response{code: 404} = Router.handle(server.id, "GET", "/whatever", %{})
    end

    test "handle/4 returns error given disabled server, and existing method and path", %{user: user, server: server, arrow: arrow} do
      {:ok, server} = Servers.update_server(user, server, %{enabled: false})
      assert %Response{code: 404} = Router.handle(server.id, arrow.method, arrow.path, %{})
    end

    test "handle/4 returns error given non-existent server", %{arrow: arrow} do
      fake_server_id = Ecto.UUID.autogenerate()
      assert %Response{code: 404} = Router.handle(fake_server_id, arrow.method, arrow.path, %{})
    end
  end
end
