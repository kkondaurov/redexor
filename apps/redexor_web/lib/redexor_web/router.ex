defmodule RedexorWeb.Router do
  use RedexorWeb, :router

  import Phoenix.LiveDashboard.Router

  import RedexorWeb.UserAuth

  import RedexorWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_current_admin
    plug :put_root_layout, {RedexorWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RedexorWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", RedexorWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/", RedexorWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    scope "/admins" do
      get "/admins/log_in", AdminSessionController, :new
      post "/admins/log_in", AdminSessionController, :create
    end
  end

  scope "/", RedexorWeb do
    pipe_through [:browser, :require_authenticated_admin]

    scope "/admins" do
      get "/settings", AdminSettingsController, :edit
      put "/settings", AdminSettingsController, :update
      get "/settings/confirm_email/:token", AdminSettingsController, :confirm_email
    end

    live_dashboard "/live_dashboard",
      metrics: RedexorWeb.Telemetry,
      ecto_repos: [Redexor.Repo]
  end

  scope "/", RedexorWeb do
    pipe_through [:browser]

    scope "/admins" do
      delete "/log_out", AdminSessionController, :delete
    end
  end

  ## Authentication routes

  scope "/", RedexorWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    scope "/users" do
      get "/register", UserRegistrationController, :new
      post "/register", UserRegistrationController, :create
      get "/log_in", UserSessionController, :new
      post "/log_in", UserSessionController, :create
      get "/reset_password", UserResetPasswordController, :new
      post "/reset_password", UserResetPasswordController, :create
      get "/reset_password/:token", UserResetPasswordController, :edit
      put "/reset_password/:token", UserResetPasswordController, :update
    end
  end

  scope "/", RedexorWeb do
    pipe_through [:browser, :require_authenticated_user]

    scope "/users" do
      get "/settings", UserSettingsController, :edit
      put "/settings", UserSettingsController, :update
      get "/settings/confirm_email/:token", UserSettingsController, :confirm_email
    end

    scope "/servers" do
      live "/", ServerLive.Index, :index
      live "/new", ServerLive.Index, :new
      live "/:id/edit", ServerLive.Index, :edit

      live "/:id", ServerLive.Show, :show
      live "/:id/show/edit", ServerLive.Show, :edit

      live "/:id/routes/new", ServerLive.Show, :new_route
      live "/:id/routes/:arrow_id/edit", ServerLive.Show, :edit_route

      live "/:id/routes/:arrow_id/", ArrowLive.Show, :show
      live "/:id/routes/:arrow_id/log", ArrowLive.Log, :index
      live "/:id/routes/:arrow_id/responses/new", ArrowLive.Show, :new_response
      live "/:id/routes/:arrow_id/responses/:response_id/edit", ArrowLive.Show, :edit_response
    end
  end

  scope "/", RedexorWeb do
    pipe_through [:browser]

    scope "/users" do
      delete "/log_out", UserSessionController, :delete
      get "/confirm", UserConfirmationController, :new
      post "/confirm", UserConfirmationController, :create
      get "/confirm/:token", UserConfirmationController, :edit
      post "/confirm/:token", UserConfirmationController, :update
    end
  end

end
