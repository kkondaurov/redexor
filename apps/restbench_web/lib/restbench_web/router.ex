defmodule RestbenchWeb.Router do
  use RestbenchWeb, :router

  import RestbenchWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RestbenchWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RestbenchWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RestbenchWeb.Telemetry, ecto_repos: [Restbench.Repo]
    end
  end

  ## Authentication routes

  scope "/", RestbenchWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    scope "/admins" do
      get "/admins/log_in", AdminSessionController, :new
      post "/admins/log_in", AdminSessionController, :create
    end
  end

  scope "/", RestbenchWeb do
    pipe_through [:browser, :require_authenticated_admin]

    scope "/admins" do
      get "/settings", AdminSettingsController, :edit
      put "/settings", AdminSettingsController, :update
      get "/settings/confirm_email/:token", AdminSettingsController, :confirm_email
    end
  end

  scope "/", RestbenchWeb do
    pipe_through [:browser]

    scope "/admins" do
      delete "/log_out", AdminSessionController, :delete
    end
  end
end
