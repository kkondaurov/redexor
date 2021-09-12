defmodule Restbench.MockServersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Restbench.MockServers` context.
  """

  @doc """
  Generate a mock_server.
  """
  def mock_server_fixture(user, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{
      enabled: true,
      title: "some title"
    })
    {:ok, mock_server} = Restbench.MockServers.create_mock_server(user, attrs)
    mock_server
  end
end
