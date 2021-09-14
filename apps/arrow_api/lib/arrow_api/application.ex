defmodule ArrowApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ArrowApi.Telemetry,
      # Start the Endpoint (http/https)
      ArrowApi.Endpoint
      # Start a worker by calling: ArrowApi.Worker.start_link(arg)
      # {ArrowApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ArrowApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ArrowApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
