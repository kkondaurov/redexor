# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :redexor, Redexor.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :redexor_web, RedexorWeb.Endpoint,
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  config :rdx_route_api, RdxRouteApi.Endpoint,
    http: [
      port: String.to_integer(System.get_env("API_PORT") || "4001"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  # ## Using releases (Elixir v1.9+)
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:

  config :redexor_web, RedexorWeb.Endpoint, server: true
  config :rdx_route_api, RdxRouteApi.Endpoint, server: true

  mailjet_api_key =
    System.get_env("MAILJET_API_KEY") ||
      raise """
      environment variable MAILJET_API_KEY is missing.
      """

  mailjet_api_secret =
    System.get_env("MAILJET_API_SECRET") ||
      raise """
      environment variable MAILJET_API_SECRET is missing.
      """

  config :redexor, Redexor.Mailer,
    adapter: Swoosh.Adapters.Mailjet,
    api_key: mailjet_api_key,
    secret: mailjet_api_secret

  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
