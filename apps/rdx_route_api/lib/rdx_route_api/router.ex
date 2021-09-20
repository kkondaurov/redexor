defmodule RdxRouteApi.Router do
  use RdxRouteApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RdxRouteApi do
    forward "/", Plugs.DynamicRouter
  end

end
