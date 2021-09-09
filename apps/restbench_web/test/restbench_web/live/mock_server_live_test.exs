defmodule RestbenchWeb.MockServerLiveTest do
  use RestbenchWeb.ConnCase

  import Phoenix.LiveViewTest
  import Restbench.MockServersFixtures
  alias Restbench.AccountsFixtures
  alias RestbenchWeb.UserAuth

  require Logger

  @create_attrs %{enabled: true, title: "some title"}
  @update_attrs %{enabled: false, title: "some updated title"}
  @invalid_attrs %{enabled: false, title: nil}

  defp create_mock_server(%{user: user}) do
    %{mock_server: mock_server_fixture(user)}
  end

  defp create_user(_) do
    %{user: AccountsFixtures.user_fixture()}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RestbenchWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "Index" do
    setup [:create_user, :create_mock_server]

    test "lists all mock_servers", %{conn: conn, user: user, mock_server: mock_server} do
      conn = authenticate_user(conn, user)

      {:ok, _index_live, html} = live(conn, Routes.mock_server_index_path(conn, :index))

      assert html =~ "Listing Mock Servers"
      assert html =~ mock_server.title
    end

    test "saves new mock_server", %{conn: conn, user: user} do
      conn = authenticate_user(conn, user)
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

    test "updates mock_server in listing", %{conn: conn, user: user, mock_server: mock_server} do
      conn = authenticate_user(conn, user)
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

    test "deletes mock_server in listing", %{conn: conn, user: user, mock_server: mock_server} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.mock_server_index_path(conn, :index))

      assert index_live |> element("#mock_server-#{mock_server.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mock_server-#{mock_server.id}")
    end
  end

  describe "Show" do
    setup [:create_user, :create_mock_server]

    test "displays mock_server", %{conn: conn, user: user, mock_server: mock_server} do
      conn = authenticate_user(conn, user)
      {:ok, _show_live, html} = live(conn, Routes.mock_server_show_path(conn, :show, mock_server))

      assert html =~ mock_server.title
    end
  end
end
