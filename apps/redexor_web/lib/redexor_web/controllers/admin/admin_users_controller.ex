defmodule RedexorWeb.AdminUsersController do
  use RedexorWeb, :controller

  alias Redexor.Accounts
  alias Redexor.Servers

  def index(conn, _params) do
    users = Accounts.list()
    render(conn, "index.html", users: users)
  end

  def toggle_blocked(conn, %{"id" => user_id}) do
    user_id
    |> Accounts.get_user!()
    |> Accounts.toggle_blocked!()

    redirect(conn, to: Routes.admin_users_path(conn, :index))
  end
end
