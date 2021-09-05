defmodule RestbenchWeb.MockServerLiveTest do
  use RestbenchWeb.ConnCase

  import Phoenix.LiveViewTest
  import Restbench.MockServersFixtures
  import Restbench.AccountsFixtures
  alias RestbenchWeb.UserAuth

  @create_attrs %{enabled: true, title: "some title"}
  @update_attrs %{enabled: false, title: "some updated title"}
  @invalid_attrs %{enabled: false, title: nil}

  defp create_mock_server(_) do
    mock_server = mock_server_fixture()
    %{mock_server: mock_server}
  end

  defp authenticate_user(%{conn: conn}) do
    user = user_fixture()

    conn =
      conn
      |> Map.replace!(:secret_key_base, RestbenchWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})
      |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
      |> recycle()

    %{user: user, conn: conn}
  end

  describe "Index" do
    setup [:authenticate_user, :create_mock_server]

    test "lists all mock_servers", %{conn: conn, mock_server: mock_server} do
      {:ok, _index_live, html} = live(conn, Routes.mock_server_index_path(conn, :index))

      assert html =~ "Listing Mock Servers"
      assert html =~ mock_server.title
    end

    test "saves new mock_server", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.mock_server_index_path(conn, :index))

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Mock Server"

      assert_patch(index_live, Routes.mock_server_index_path(conn, :new))

      assert index_live
             |> form("#mock_server-form", mock_server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#mock_server-form", mock_server: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.mock_server_index_path(conn, :index))

      assert html =~ "Mock Server created successfully"
      assert html =~ "some title"
    end

    test "updates mock_server in listing", %{conn: conn, mock_server: mock_server} do
      {:ok, index_live, _html} = live(conn, Routes.mock_server_index_path(conn, :index))

      assert index_live |> element("#mock_server-#{mock_server.id} a", "Edit") |> render_click() =~
               "Edit"

      assert_patch(index_live, Routes.mock_server_index_path(conn, :edit, mock_server))

      assert index_live
             |> form("#mock_server-form", mock_server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#mock_server-form", mock_server: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.mock_server_index_path(conn, :index))

      assert html =~ "Mock Server updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes mock_server in listing", %{conn: conn, mock_server: mock_server} do
      {:ok, index_live, _html} = live(conn, Routes.mock_server_index_path(conn, :index))

      assert index_live |> element("#mock_server-#{mock_server.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mock_server-#{mock_server.id}")
    end
  end

  describe "Show" do
    setup [:authenticate_user, :create_mock_server]

    test "displays mock_server", %{conn: conn, mock_server: mock_server} do
      {:ok, _show_live, html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert html =~ "Show Mock Server"
      assert html =~ mock_server.title
    end

    test "updates mock_server within modal", %{conn: conn, mock_server: mock_server} do
      {:ok, show_live, _html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mock Server"

      assert_patch(show_live, Routes.mock_server_show_path(conn, :edit, mock_server))

      assert show_live
             |> form("#mock_server-form", mock_server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#mock_server-form", mock_server: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert html =~ "Mock Server updated successfully"
      assert html =~ "some updated title"
    end
  end
end
