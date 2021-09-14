defmodule Restbench.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Accounts.User
  alias Restbench.Admins.Admin
  alias Restbench.Servers.Server
  alias Restbench.Repo

  @spec list_servers(User.t()) :: [Server.t()]
  def list_servers(user) do
    Server
    |> scope(user)
    |> order_by([s], desc: s.id)
    |> Repo.all()
  end

  @spec get_server(User.t(), String.t()) :: Server.t() | nil
  def get_server(user, id) do
    Server
    |> scope(user)
    |> Repo.get(id)
  end

  @spec create_server(User.t() | Admin.t(), map()) ::
          {:ok, Server.t()} | {:error, Ecto.Changeset.t()}
  def create_server(%User{id: user_id}, attrs) do
    %Server{}
    |> Ecto.Changeset.change(user_id: user_id)
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  def create_server(%Admin{}, attrs) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_server(User.t() | Admin.t(), Server.t(), map()) ::
          {:ok, Server.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_server(%User{id: user_id}, %Server{user_id: user_id} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  def update_server(%Admin{}, %Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  def update_server(_user, _server, _attrs), do: {:error, :unauthorized}

  @spec delete_server(User.t() | Admin.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_server(%User{id: user_id}, %Server{user_id: user_id} = server) do
    Repo.delete(server)
  end

  def delete_server(%Admin{}, %Server{} = server) do
    Repo.delete(server)
  end

  def delete_server(_user, _server), do: {:error, :unauthorized}

  @spec change_server(Server.t(), map()) :: Ecto.Changeset.t()
  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  @spec toggle_server(User.t(), Server.t()) ::
          {:ok, Server.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def toggle_server(
        %User{id: user_id},
        %Server{user_id: user_id, enabled: enabled?} = server
      ) do
    server
    |> Server.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end

  def toggle_server(_, _), do: {:error, :unauthorized}

  defp scope(queryable, %User{id: user_id}) do
    queryable
    |> where([ms], ms.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable
end
