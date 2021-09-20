defmodule Redexor.Support.RdxRoutesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Redexor.RdxRoutes` context.
  """

  @doc """
  Generate a rdx_route.
  """
  def rdx_route_fixture(user, server, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        enabled: true,
        method: "GET",
        path: "/some/path",
        title: "some title"
      })

    {:ok, rdx_route} = Redexor.RdxRoutes.create_rdx_route(user, server, attrs)
    rdx_route
  end
end
