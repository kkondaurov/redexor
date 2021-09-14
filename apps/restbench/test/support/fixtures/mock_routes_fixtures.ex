defmodule Restbench.ArrowsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Restbench.Arrows` context.
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

    {:ok, arrow} = Restbench.Arrows.create_arrow(user, server, attrs)
    arrow
  end
end
