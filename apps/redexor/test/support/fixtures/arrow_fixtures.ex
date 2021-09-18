defmodule Redexor.Support.ArrowsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Redexor.Arrows` context.
  """

  @doc """
  Generate a arrow.
  """
  def arrow_fixture(user, server, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        enabled: true,
        method: "GET",
        path: "/some/path",
        title: "some title"
      })

    {:ok, arrow} = Redexor.Arrows.create_arrow(user, server, attrs)
    arrow
  end
end
