defmodule Restbench.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Restbench.Repo,
      # Start the PubSub system
      #{Phoenix.PubSub, name: Restbench.PubSub}
      # Start a worker by calling: Restbench.Worker.start_link(arg)
      # {Restbench.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Restbench.Supervisor)
  end
end
