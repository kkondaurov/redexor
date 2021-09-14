defmodule RestbenchWeb.UserRegistrationControllerTest do
  use RestbenchWeb.ConnCase, async: true

  import Restbench.Support.AccountsFixtures

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
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
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Log out</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
