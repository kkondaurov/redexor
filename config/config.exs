# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :redexor,
  ecto_repos: [Redexor.Repo.Local]

config :fly_postgres, :local_repo, Redexor.Repo.Local

config :redexor, Redexor.Repo.Local,
  priv: "priv/repo"

# Configures the endpoint
config :redexor, RedexorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FcLC40aHlktfR8s7rP5066avsylnjWjTpNVmKn3Jn/zIq49XNG0k/UuOLLOY0LgM",
  render_errors: [view: RedexorWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Redexor.PubSub,
  live_view: [signing_salt: "r3cnCcPZ"]

# Configures the endpoint
config :redexor, RdxRouteApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cYsLmRjGM1s7hIMYFLna+udEAlDrQmApQNi5R7XeFGttqxtDCL1ARcpRC6P4VFzV",
  render_errors: [view: RdxRouteApi.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Redexor.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :redexor, Redexor.Mailer, adapter: Swoosh.Adapters.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
