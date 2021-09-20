defmodule Redexor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Redexor.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Redexor.PubSub},
      Redexor.RequestLogger
      # Start a worker by calling: Redexor.Worker.start_link(arg)
      # {Redexor.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Redexor.Supervisor)
  end
end
