defmodule RestbenchWeb.ArrowLiveTest do
  use RestbenchWeb.ConnCase

  import Phoenix.LiveViewTest
  import Restbench.Support.ArrowsFixtures
  alias Restbench.Support.AccountsFixtures
  alias Restbench.Support.ServersFixtures
  alias RestbenchWeb.UserAuth

  @create_attrs %{enabled: true, method: "GET", path: "some path", title: "some title"}
  @update_attrs %{
    enabled: false,
    method: "POST",
    path: "some updated path",
    title: "some updated title"
  }
  @invalid_attrs %{enabled: false, method: nil, path: nil, title: nil}

  defp create_arrow(_) do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    arrow = arrow_fixture(user, server)
    %{arrow: arrow, user: user, server: server}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RestbenchWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "Index" do
    setup [:create_arrow]

    test "lists all arrows", %{
      conn: conn,
      user: user,
      server: server,
      arrow: arrow
    } do
      conn = authenticate_user(conn, user)

      {:ok, _index_live, html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ arrow.title
      assert html =~ arrow.method
    end

    test "saves new arrow", %{conn: conn, user: user, server: server} do
      conn = authenticate_user(conn, user)

      {:ok, index_live, _html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Route"

      assert_patch(index_live, Routes.server_show_path(conn, :new_route, server.id))

      assert index_live
             |> form("#arrow-form", arrow: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#arrow-form", arrow: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ "Route created successfully"
      assert html =~ "GET"
    end

    test "updates arrow in listing", %{
      conn: conn,
      user: user,
      server: server,
      arrow: arrow
    } do
      conn = authenticate_user(conn, user)

      {:ok, index_live, _html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert index_live |> element("#arrow-#{arrow.id} a", "Edit") |> render_click() =~
               "Edit Route"

      assert_patch(
        index_live,
        Routes.server_show_path(conn, :edit_route, server.id, arrow.id)
      )

      assert index_live
             |> form("#arrow-form", arrow: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#arrow-form", arrow: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ "Route updated successfully"
      assert html =~ "POST"
    end

    test "deletes arrow in listing", %{
      conn: conn,
      user: user,
      server: server,
      arrow: arrow
    } do
      conn = authenticate_user(conn, user)

      {:ok, index_live, _html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert index_live |> element("#arrow-#{arrow.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#arrow-#{arrow.id}")
    end
  end
end
