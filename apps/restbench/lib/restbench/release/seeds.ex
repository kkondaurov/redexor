defmodule Restbench.Release.Seeds do

  import Ecto.Query
  alias Restbench.Admins
  alias Restbench.Admins.Admin
  alias Restbench.Repo

  def run() do
    create_admin()
  end

  defp create_admin() do
    unless Repo.exists?(from a in Admin) do
      {:ok, admin} = Admins.register_admin(
        %{
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
