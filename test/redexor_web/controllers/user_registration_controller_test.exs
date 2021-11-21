defmodule RedexorWeb.UserRegistrationControllerTest do
  use RedexorWeb.ConnCase, async: true

  import Redexor.Support.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response_template = html_response(conn, 200)
      assert response_template =~ "<h1>Register</h1>"
      assert response_template =~ "Log in</a>"
      assert response_template =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == Routes.server_index_path(conn, :index)
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()
      user_attrs = valid_user_attributes(email: email)

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => user_attrs
        })

      assert redirected_to(conn) =~ "/"

      _user = confirmed_user_by_email(email)

      # Log in and assert on the menu
      conn =
        conn
        |> recycle()
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user_attrs.email, "password" => user_attrs.password}
        })

      assert redirected_to(conn) =~ "/"
      conn = get(conn, "/")
      response_template = html_response(conn, 200)
      assert response_template =~ email
      assert response_template =~ "Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response_template = html_response(conn, 200)
      assert response_template =~ "<h1>Register</h1>"
      assert response_template =~ "must have the @ sign and no spaces"
      assert response_template =~ "should be at least 12 character"
    end
  end
end
