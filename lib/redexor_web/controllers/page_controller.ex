defmodule RedexorWeb.PageController do
  use RedexorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
