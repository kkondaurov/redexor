defmodule Redexor.RdxRoutesTest do
  use Redexor.DataCase

  alias Redexor.RdxRoutes
  alias Redexor.Support.AccountsFixtures
  alias Redexor.Support.ServersFixtures

  setup do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    {:ok, user: user, server: server}
  end

  describe "rdx_routes" do
    alias Redexor.RdxRoutes.RdxRoute

    import Redexor.Support.RdxRoutesFixtures

    @invalid_attrs %{enabled: nil, method: nil, path: nil, title: nil}

    test "list_rdx_routes/2 returns all rdx_routes", %{user: user, server: server} do
      rdx_route = rdx_route_fixture(user, server)
      assert RdxRoutes.list_rdx_routes(user, server.id) == [rdx_route]
    end

    test "get_rdx_route/1 returns the rdx_route with given id", %{
      user: user,
      server: server
    } do
      %RdxRoute{id: rdx_route_id} = rdx_route_fixture(user, server)
      assert %RdxRoute{id: ^rdx_route_id} = RdxRoutes.get_rdx_route(user, rdx_route_id)
    end

    test "create_rdx_route/3 with valid data creates a rdx_route", %{
      user: user,
      server: server
    } do
      valid_attrs = %{enabled: true, method: "GET", path: "/some path", title: "some title"}

      assert {:ok, %RdxRoute{} = rdx_route} = RdxRoutes.create_rdx_route(user, server, valid_attrs)

      assert rdx_route.enabled == true
      assert rdx_route.method == "GET"
      assert rdx_route.path == "/some path"
      assert rdx_route.title == "some title"
    end

    test "create_rdx_route/1 with invalid data returns error changeset", %{
      user: user,
      server: server
    } do
      assert {:error, %Ecto.Changeset{}} = RdxRoutes.create_rdx_route(user, server, @invalid_attrs)
    end

    test "update_rdx_route/2 with valid data updates the rdx_route", %{
      user: user,
      server: server
    } do
      rdx_route = rdx_route_fixture(user, server)

      update_attrs = %{
        enabled: false,
        method: "POST",
        path: "/some updated path",
        title: "some updated title"
      }

      assert {:ok, %RdxRoute{} = rdx_route} = RdxRoutes.update_rdx_route(user, rdx_route, update_attrs)

      assert rdx_route.enabled == false
      assert rdx_route.method == "POST"
      assert rdx_route.path == "/some updated path"
      assert rdx_route.title == "some updated title"
    end

    test "update_rdx_route/2 with invalid data returns error changeset", %{
      user: user,
      server: server
    } do
      %RdxRoute{
        id: rdx_route_id,
        enabled: enabled,
        method: method,
        path: path,
        title: title
      } = rdx_route = rdx_route_fixture(user, server)

      assert {:error, %Ecto.Changeset{}} = RdxRoutes.update_rdx_route(user, rdx_route, @invalid_attrs)

      assert %RdxRoute{
        id: ^rdx_route_id,
        enabled: ^enabled,
        method: ^method,
        path: ^path,
        title: ^title
      } = RdxRoutes.get_rdx_route(user, rdx_route_id)
    end

    test "update_rdx_route/2 adds a leading slash", %{
      user: user,
      server: server
    } do
      rdx_route = rdx_route_fixture(user, server)

      assert {:ok, %RdxRoute{} = rdx_route} =
               RdxRoutes.update_rdx_route(user, rdx_route, %{path: "path/without/leading/shash"})

      assert rdx_route.path == "/path/without/leading/shash"
    end

    test "update_rdx_route/2 with duplicate path and method", %{
      user: user,
      server: server
    } do
      rdx_route = rdx_route_fixture(user, server)

      assert {:error, %Ecto.Changeset{}} =
               RdxRoutes.create_rdx_route(user, server, %{
                 title: "duplicate path and method",
                 path: rdx_route.path,
                 method: rdx_route.method,
                 enabled: true
               })

      assert {:error, %Ecto.Changeset{}} =
               RdxRoutes.create_rdx_route(user, server, %{
                 title: "duplicate path and method",
                 path: rdx_route.path,
                 method: rdx_route.method,
                 enabled: false
               })
    end

    test "delete_rdx_route/2 deletes the rdx_route", %{user: user, server: server} do
      rdx_route = rdx_route_fixture(user, server)
      assert {:ok, %RdxRoute{}} = RdxRoutes.delete_rdx_route(user, rdx_route)
      assert is_nil(RdxRoutes.get_rdx_route(user, rdx_route.id))
    end

    test "change_rdx_route/2 returns a rdx_route changeset", %{
      user: user,
      server: server
    } do
      rdx_route = rdx_route_fixture(user, server)
      assert %Ecto.Changeset{} = RdxRoutes.change_rdx_route(rdx_route)
    end
  end
end
