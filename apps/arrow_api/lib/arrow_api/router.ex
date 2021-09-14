defmodule ArrowApi.Router do
  use ArrowApi, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ArrowApi do
    forward "/", Plugs.DynamicRouter
  end

end
