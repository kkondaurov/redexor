defmodule RedexorWeb.ServerLiveTest do
  use RedexorWeb.ConnCase

  import Phoenix.LiveViewTest
  import Redexor.Support.ServersFixtures
  alias Redexor.Support.AccountsFixtures
  alias RedexorWeb.UserAuth

  require Logger

  @create_attrs %{enabled: true, title: "some title"}
  @update_attrs %{enabled: false, title: "some updated title"}
  @invalid_attrs %{enabled: false, title: nil}

  defp create_server(%{user: user}) do
    %{server: server_fixture(user)}
  end

  defp create_user(_) do
    %{user: AccountsFixtures.user_fixture()}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RedexorWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "Index" do
    setup [:create_user, :create_server]

    test "lists all servers", %{conn: conn, user: user, server: server} do
      conn = authenticate_user(conn, user)

      {:ok, _index_live, html} = live(conn, Routes.server_index_path(conn, :index))

      assert html =~ "Listing Servers"
      assert html =~ server.title
    end

    test "saves new server", %{conn: conn, user: user} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.server_index_path(conn, :index))

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Server"

      assert_patch(index_live, Routes.server_index_path(conn, :new))

      assert index_live
             |> form("#server-form", server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#server-form", server: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.server_index_path(conn, :index))

      assert html =~ "Server created successfully"
      assert html =~ "some title"
    end

    test "updates server in listing", %{conn: conn, user: user, server: server} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.server_index_path(conn, :index))

      assert index_live |> element("#server-#{server.id} a", "Edit") |> render_click() =~
               "Edit"

      assert_patch(index_live, Routes.server_index_path(conn, :edit, server))

      assert index_live
             |> form("#server-form", server: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#server-form", server: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.server_index_path(conn, :index))

      assert html =~ "Server updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes server in listing", %{conn: conn, user: user, server: server} do
      conn = authenticate_user(conn, user)
      {:ok, index_live, _html} = live(conn, Routes.server_index_path(conn, :index))

      assert index_live |> element("#server-#{server.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#server-#{server.id}")
    end
  end

  describe "Show" do
    setup [:create_user, :create_server]

    test "displays server", %{conn: conn, user: user, server: server} do
      conn = authenticate_user(conn, user)
      {:ok, _show_live, html} = live(conn, Routes.server_show_path(conn, :show, server))

      assert html =~ server.title
    end
  end
end
