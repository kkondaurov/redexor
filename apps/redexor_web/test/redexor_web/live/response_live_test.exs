defmodule RedexorWeb.ResponseLiveTest do
  use RedexorWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Redexor.Support.RdxRoutesFixtures
  alias Redexor.Support.AccountsFixtures
  alias Redexor.Support.ServersFixtures
  alias RedexorWeb.UserAuth

  @create_attrs %{
    title: "Valid response_template",
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

  defp create_rdx_route(_) do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    rdx_route = RdxRoutesFixtures.rdx_route_fixture(user, server)
    %{rdx_route: rdx_route, user: user, server: server}
  end

  defp authenticate_user(conn, user) do
    conn
    |> Map.replace!(:secret_key_base, RedexorWeb.Endpoint.config(:secret_key_base))
    |> init_test_session(%{})
    |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    |> recycle()
  end

  describe "RdxRouteShow" do
    setup [:create_rdx_route]

    test "given a route without response_templates, a created response_template is listed for the route",
         %{
           conn: conn,
           user: user,
           server: server,
           rdx_route: rdx_route
         } do
      conn = authenticate_user(conn, user)

      {:ok, show_live, html} =
        live(conn, Routes.rdx_route_show_path(conn, :show, server, rdx_route))

      assert html =~ rdx_route.title

      assert show_live |> element("a", "Create") |> render_click() =~
               "New Response Template"

      assert_patch(
        show_live,
        Routes.rdx_route_show_path(conn, :new_response, server.id, rdx_route.id)
      )

      assert show_live
             |> form("#response_template-form", response_template: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _show_live, html} =
        show_live
        |> form("#response_template-form", response_template: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.rdx_route_show_path(conn, :show, server.id, rdx_route.id))

      assert html =~ "Response Template created successfully"
      assert html =~ @create_attrs.title
    end

    test "response_template can be selected", %{
      conn: conn,
      user: user,
      server: server,
      rdx_route: rdx_route
    } do
      conn = authenticate_user(conn, user)

      {:ok, show_live, _html} =
        live(conn, Routes.rdx_route_show_path(conn, :show, server, rdx_route))

      # Create first response_template
      assert show_live |> element("a", "Create") |> render_click() =~ "New Response Template"

      assert_patch(
        show_live,
        Routes.rdx_route_show_path(conn, :new_response, server.id, rdx_route.id)
      )

      {:ok, show_live, html} =
        show_live
        |> form("#response_template-form", response_template: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.rdx_route_show_path(conn, :show, server.id, rdx_route.id))

      assert html =~ "Response Template created successfully"
      assert html =~ @create_attrs.title

      # Select the created response_template
      assert show_live |> element("a.select-response_template") |> render_click()

      assert show_live |> element("#response_template tr", @create_attrs.title) |> render() =~
               "default-response_template"
    end
  end
end
