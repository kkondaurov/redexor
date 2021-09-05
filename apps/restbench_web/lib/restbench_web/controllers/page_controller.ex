defmodule RestbenchWeb.PageController do
  use RestbenchWeb, :controller

  def index(conn, _params) do
    case conn.assigns.current_user do
      nil -> render(conn, "index.html")
      _user -> render(conn, "dashboard.html")
    end
  end
end
