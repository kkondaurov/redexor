defmodule RedexorWeb.RdxRouteLiveTest do
  use RedexorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Redexor.Support.RdxRoutesFixtures
  alias Redexor.Support.AccountsFixtures
  alias Redexor.Support.ServersFixtures
  alias RedexorWeb.UserAuth

  @create_attrs %{enabled: true, method: "GET", path: "some path", title: "some title"}
  @update_attrs %{
    enabled: false,
    method: "POST",
    path: "some updated path",
    title: "some updated title"
  }
  @invalid_attrs %{enabled: false, method: "PUT", path: nil, title: nil}

  defp create_rdx_route(_) do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    rdx_route = rdx_route_fixture(user, server)
    %{rdx_route: rdx_route, user: user, server: server}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RedexorWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "ServerShow" do
    setup [:create_rdx_route]

    test "lists all rdx_routes", %{
      conn: conn,
      user: user,
      server: server,
      rdx_route: rdx_route
    } do
      conn = authenticate_user(conn, user)

      {:ok, _index_live, html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ rdx_route.title
      assert html =~ rdx_route.method
    end

    test "saves new rdx_route", %{conn: conn, user: user, server: server} do
      conn = authenticate_user(conn, user)

      {:ok, index_live, _html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Route"

      assert_patch(index_live, Routes.server_show_path(conn, :new_route, server.id))

      assert index_live
             |> form("#rdx_route-form", rdx_route: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#rdx_route-form", rdx_route: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ "Route created successfully"
      assert html =~ "GET"
    end

    test "updates rdx_route in listing", %{
      conn: conn,
      user: user,
      server: server,
      rdx_route: rdx_route
    } do
      conn = authenticate_user(conn, user)

      {:ok, index_live, _html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert index_live |> element("#rdx_route-#{rdx_route.id} a", "Edit") |> render_click() =~
               "Edit Route"

      assert_patch(
        index_live,
        Routes.server_show_path(conn, :edit_route, server.id, rdx_route.id)
      )

      assert index_live
             |> form("#rdx_route-form", rdx_route: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#rdx_route-form", rdx_route: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ "Route updated successfully"
      assert html =~ "POST"
    end

    test "deletes rdx_route in listing", %{
      conn: conn,
      user: user,
      server: server,
      rdx_route: rdx_route
    } do
      conn = authenticate_user(conn, user)

      {:ok, index_live, _html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert index_live |> element("#rdx_route-#{rdx_route.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rdx_route-#{rdx_route.id}")
    end
  end
end
