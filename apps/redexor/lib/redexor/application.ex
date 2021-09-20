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
      # Start a worker by calling: Redexor.Worker.start_link(arg)
      # {Redexor.Worker, arg}
    ] ++ children_for_env(Mix.env())

    Supervisor.start_link(children, strategy: :one_for_one, name: Redexor.Supervisor)
  end

  def children_for_env(:test), do: []
  def children_for_env(_), do: [Redexor.RequestLogger]
end
