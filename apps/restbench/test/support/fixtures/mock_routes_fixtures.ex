defmodule Restbench.MockRoutesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Restbench.MockRoutes` context.
  """

  @doc """
  Generate a mock_route.
  """
  def mock_route_fixture(user, mock_server, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        enabled: true,
        method: "GET",
        path: "/some/path",
        title: "some title"
      })
    {:ok, mock_route} = Restbench.MockRoutes.create_mock_route(user, mock_server, attrs)
    mock_route
  end
end
