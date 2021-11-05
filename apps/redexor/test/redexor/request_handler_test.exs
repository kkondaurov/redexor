defmodule Redexor.RequestHandlerTest do
  use Redexor.DataCase

  alias Redexor.RdxRoutes
  alias Redexor.RequestHandler
  alias Redexor.RequestHandler.ApiResponse
  alias Redexor.ResponseTemplates
  alias Redexor.Servers
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
    {:ok, rdx_route: rdx_route, user: user, server: server}
  end

  describe "Test servers, methods and paths" do
    test "handle/4 returns empty response_template given enabled server and route without a configured response_template",
         %{server: server, rdx_route: rdx_route} do
      assert %ApiResponse{code: 200, payload: %{}} =
               RequestHandler.handle(server.id, rdx_route.method, rdx_route.path, %{}, %{})
    end

    test "handle/4 returns configured text response_template", %{
      server: server,
      user: user,
      rdx_route: rdx_route
    } do
      {:ok, response_template} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "TEXT",
          text_body: "hello world!",
          title: "response_template title"
        })

      {:ok, _} = ResponseTemplates.set_selected(user, response_template)

      assert %ApiResponse{code: 403, payload: "hello world!"} =
               RequestHandler.handle(server.id, rdx_route.method, rdx_route.path, %{}, %{})
    end

    test "handle/4 returns configured json response_template", %{
      server: server,
      user: user,
      rdx_route: rdx_route
    } do
      {:ok, response_template} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "JSON",
          json_body: "{\"foo\":\"bar\"}",
          title: "response_template title"
        })

      {:ok, _} = ResponseTemplates.set_selected(user, response_template)

      assert %ApiResponse{code: 403, payload: %{"foo" => "bar"}} =
               RequestHandler.handle(server.id, rdx_route.method, rdx_route.path, %{}, %{})
    end

    test "handle/4 returns error given an enabled server, but method and path of a disabled rdx_route",
         %{user: user, server: server, rdx_route: rdx_route} do
      {:ok, rdx_route} = RdxRoutes.update_rdx_route(user, rdx_route, %{enabled: false})

      assert %ApiResponse{code: 404} =
               RequestHandler.handle(server.id, rdx_route.method, rdx_route.path, %{}, %{})
    end

    test "handle/4 returns error given an enabled server, but non-existent path and method", %{
      server: server
    } do
      assert %ApiResponse{code: 404} =
               RequestHandler.handle(server.id, "GET", "/whatever", %{}, %{})
    end

    test "handle/4 returns error given a disabled server and existing method and path", %{
      user: user,
      server: server,
      rdx_route: rdx_route
    } do
      {:ok, server} = Servers.update_server(user, server, %{enabled: false})

      assert %ApiResponse{code: 404} =
               RequestHandler.handle(server.id, rdx_route.method, rdx_route.path, %{}, %{})
    end

    test "handle/4 returns error given a non-existent server", %{rdx_route: rdx_route} do
      fake_server_id = Ecto.UUID.autogenerate()

      assert %ApiResponse{code: 404} =
               RequestHandler.handle(fake_server_id, rdx_route.method, rdx_route.path, %{}, %{})
    end
  end
end
