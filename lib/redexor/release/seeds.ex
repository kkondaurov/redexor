defmodule Redexor.Release.Seeds do
  @moduledoc false

  import Ecto.Query
  alias Redexor.Admins
  alias Redexor.Admins.Admin
  alias Redexor.Repo

  def run do
    create_admin()
  end

  defp create_admin do
    unless Repo.exists?(from(a in Admin)) do
      {:ok, admin} =
        Admins.register_admin(%{
          email: "changeme@example.com",
          password: "changemeasap",
          superadmin: true,
          confirmed_at: DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)
        })

      admin
      |> Ecto.Changeset.change(%{
        superadmin: true,
        confirmed_at: DateTime.now!("Etc/UTC") |> DateTime.truncate(:second)
      })
      |> Repo.update!()
    end
  end
end
