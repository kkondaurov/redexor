defmodule RestbenchWeb.UserSessionController do
  use RestbenchWeb, :controller

  alias Restbench.Accounts
  alias RestbenchWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    with {:user_exists, user} when not is_nil(user) <-
           {:user_exists, Accounts.get_user_by_email_and_password(email, password)},
         {:user_confirmed, true} <- {:user_confirmed, not is_nil(user.confirmed_at)} do
      UserAuth.log_in_user(conn, user, user_params)
    else
      _ ->
        # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
        render(conn, "new.html", error_message: "Invalid email or password.")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
