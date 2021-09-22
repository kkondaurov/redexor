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
        {Phoenix.PubSub, name: Redexor.PubSub}
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
end
