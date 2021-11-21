defmodule Redexor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        Redexor.Repo,
        # Start the PubSub system
        {Phoenix.PubSub, name: Redexor.PubSub},
        # Start the Telemetry supervisor
        RedexorWeb.Telemetry,
        # Start the Endpoint (http/https)
        RedexorWeb.Endpoint,
        # Start the Telemetry supervisor
        RdxRouteApi.Telemetry,
        # Start the Endpoint (http/https)
        RdxRouteApi.Endpoint
        # Start a worker by calling: Redexor.Worker.start_link(arg)
        # {Redexor.Worker, arg}
      ] ++ request_logger_config()

    Supervisor.start_link(children, strategy: :one_for_one, name: Redexor.Supervisor)
  end

  def request_logger_config do
    if Application.get_env(:redexor, :disable_request_logger) do
      []
    else
      [Redexor.RequestLogger]
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RedexorWeb.Endpoint.config_change(changed, removed)
    RdxRouteApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
