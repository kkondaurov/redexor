defmodule Redexor.Support.ServersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Redexor.Servers` context.
  """

  @doc """
  Generate a server.
  """
  def server_fixture(user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        enabled: true,
        title: "some title"
      })

    {:ok, server} = Redexor.Servers.create_server(user, attrs)
    server
  end
end
