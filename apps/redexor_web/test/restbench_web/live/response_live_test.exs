defmodule RedexorWeb.ResponseLiveTest do
  use RedexorWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Redexor.Support.ArrowsFixtures
  alias Redexor.Support.AccountsFixtures
  alias Redexor.Support.ServersFixtures
  alias RedexorWeb.UserAuth

  @create_attrs %{
    title: "Valid response",
    code: 404,
    type: "TEXT",
    json_body: "",
    text_body: "HeLLo wOrlD"
  }

  @invalid_attrs %{
    title: nil,
    code: nil,
    type: "JSON",
    json_body: nil,
    text_body: nil
  }

  defp create_arrow(_) do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    arrow = ArrowsFixtures.arrow_fixture(user, server)
    %{arrow: arrow, user: user, server: server}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RedexorWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "ArrowShow" do
    setup [:create_arrow]

    test "given a route without responses, a created response is listed for the route and is its default", %{
      conn: conn,
      user: user,
      server: server,
      arrow: arrow
    } do
      conn = authenticate_user(conn, user)

      {:ok, index_live, html} = live(conn, Routes.arrow_show_path(conn, :show, server, arrow))

      assert html =~ arrow.title

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Response"

      assert_patch(index_live, Routes.arrow_show_path(conn, :new_response, server.id, arrow.id))

      assert index_live
             |> form("#response-form", response: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, show_live, html} =
        index_live
        |> form("#response-form", response: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.arrow_show_path(conn, :show, server.id, arrow.id))

      assert html =~ "Response created successfully"
      assert html =~ @create_attrs.title
      assert show_live |> element("#response", @create_attrs.title) |> render() =~ "default-response"
    end

    test "given a route with a response, a created response is listed, but route's default response is unchanged", %{
      conn: conn,
      user: user,
      server: server,
      arrow: arrow
    } do
      conn = authenticate_user(conn, user)

      {:ok, index_live, html} = live(conn, Routes.arrow_show_path(conn, :show, server, arrow))

      assert html =~ arrow.title

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Response"

      assert_patch(index_live, Routes.arrow_show_path(conn, :new_response, server.id, arrow.id))

      assert index_live
             |> form("#response-form", response: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, show_live, html} =
        index_live
        |> form("#response-form", response: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.arrow_show_path(conn, :show, server.id, arrow.id))

      assert html =~ "Response created successfully"
      assert html =~ @create_attrs.title
      assert show_live |> element("#response tr", @create_attrs.title) |> render() =~ "default-response"

      # "Reload" the page
      {:ok, index_live, html} = live(conn, Routes.arrow_show_path(conn, :show, server, arrow))

      assert html =~ @create_attrs.title

      assert index_live |> element("a", "Create") |> render_click() =~
               "New Response"

      assert_patch(index_live, Routes.arrow_show_path(conn, :new_response, server.id, arrow.id))

      {:ok, show_live, html} =
        index_live
        |> form("#response-form", response: %{@create_attrs | title: "Second response"})
        |> render_submit()
        |> follow_redirect(conn, Routes.arrow_show_path(conn, :show, server.id, arrow.id))

      assert html =~ "Response created successfully"
      assert html =~ "Second response"
      refute show_live |> element("#response tr", "Second response") |> render() =~ "default-response"
      assert show_live |> element("#response tr", @create_attrs.title) |> render() =~ "default-response"
    end
  end
end
