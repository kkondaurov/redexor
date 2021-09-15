defmodule RestbenchWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RestbenchWeb.Telemetry,
      # Start the Endpoint (http/https)
      RestbenchWeb.Endpoint,
      {Phoenix.PubSub, name: Restbench.PubSub}
      # Start a worker by calling: RestbenchWeb.Worker.start_link(arg)
      # {RestbenchWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RestbenchWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RestbenchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
