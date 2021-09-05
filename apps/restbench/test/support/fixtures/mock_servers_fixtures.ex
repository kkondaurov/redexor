defmodule Restbench.MockServersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Restbench.MockServers` context.
  """

  @doc """
  Generate a mock_server.
  """
  def mock_server_fixture(attrs \\ %{}) do
    {:ok, mock_server} =
      attrs
      |> Enum.into(%{
        enabled: true,
        title: "some title"
      })
      |> Restbench.MockServers.create_mock_server()

    mock_server
  end
end
