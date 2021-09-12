defmodule RestbenchWeb.MockRouteLiveTest do
  use RestbenchWeb.ConnCase

  import Phoenix.LiveViewTest
  import Restbench.MockRoutesFixtures
  alias Restbench.MockServersFixtures
  alias Restbench.AccountsFixtures
  alias RestbenchWeb.UserAuth

  @create_attrs %{enabled: true, method: "GET", path: "some path", title: "some title"}
  @update_attrs %{enabled: false, method: "POST", path: "some updated path", title: "some updated title"}
  @invalid_attrs %{enabled: false, method: nil, path: nil, title: nil}

  defp create_mock_route(_) do
    user = AccountsFixtures.user_fixture()
    mock_server = MockServersFixtures.mock_server_fixture(user)
    mock_route = mock_route_fixture(user, mock_server)
    %{mock_route: mock_route, user: user, mock_server: mock_server}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RestbenchWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "Index" do
    setup [:create_mock_route]

    test "lists all mock_routes", %{conn: conn, user: user, mock_server: mock_server, mock_route: mock_route} do
      conn = authenticate_user(conn, user)
      {:ok, _index_live, html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert html =~ mock_route.title
      assert html =~ mock_route.method
    end

    test "saves new mock_route", %{conn: conn, user: user, mock_server: mock_server} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Mock Route"

      assert_patch(index_live, Routes.mock_server_show_path(conn, :new_route, mock_server.id))

      assert index_live
             |> form("#mock_route-form", mock_route: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#mock_route-form", mock_route: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert html =~ "Mock Route created successfully"
      assert html =~ "GET"
    end

    test "updates mock_route in listing", %{conn: conn, user: user, mock_server: mock_server, mock_route: mock_route} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert index_live |> element("#mock_route-#{mock_route.id} a", "Edit") |> render_click() =~
               "Edit Mock Route"

      assert_patch(index_live, Routes.mock_server_show_path(conn, :edit_route, mock_server.id, mock_route.id))

      assert index_live
             |> form("#mock_route-form", mock_route: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#mock_route-form", mock_route: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert html =~ "Mock Route updated successfully"
      assert html =~ "POST"
    end

    test "deletes mock_route in listing", %{conn: conn, user: user, mock_server: mock_server, mock_route: mock_route} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert index_live |> element("#mock_route-#{mock_route.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mock_route-#{mock_route.id}")
    end
  end
end
