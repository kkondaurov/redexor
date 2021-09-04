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
config :restbench,
  ecto_repos: [Restbench.Repo]

config :restbench_web,
  ecto_repos: [Restbench.Repo],
  generators: [context_app: :restbench]

# Configures the endpoint
config :restbench_web, RestbenchWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FcLC40aHlktfR8s7rP5066avsylnjWjTpNVmKn3Jn/zIq49XNG0k/UuOLLOY0LgM",
  render_errors: [view: RestbenchWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Restbench.PubSub,
  live_view: [signing_salt: "r3cnCcPZ"]

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
    cd: Path.expand("../apps/restbench_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :restbench, Restbench.Mailer, adapter: Swoosh.Adapters.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
