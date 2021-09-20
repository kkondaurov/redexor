defmodule RedexorWeb.AdminUsersController do
  use RedexorWeb, :controller

  alias Redexor.Accounts

  def index(conn, _params) do
    users = Accounts.list()
    render(conn, "index.html", users: users)
  end
end
