defmodule Restbench.MockServers do
  @moduledoc """
  The MockServers context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Accounts.User
  alias Restbench.Admins.Admin
  alias Restbench.MockServers.MockServer
  alias Restbench.Repo

  def list_mock_servers(user) do
    MockServer
    |> scope(user)
    |> Repo.all()
  end

  def get_mock_server(user, id) do
    MockServer
    |> scope(user)
    |> Repo.get(id)
  end

  def create_mock_server(%User{id: user_id}, attrs) do
    %MockServer{}
    |> Ecto.Changeset.change(user_id: user_id)
    |> MockServer.changeset(attrs)
    |> Repo.insert()
  end

  def create_mock_server(%Admin{}, attrs) do
    %MockServer{}
    |> MockServer.changeset(attrs)
    |> Repo.insert()
  end

  def update_mock_server(%User{id: user_id}, %MockServer{user_id: user_id} = mock_server, attrs) do
    mock_server
    |> MockServer.changeset(attrs)
    |> Repo.update()
  end

  def update_mock_server(%Admin{}, %MockServer{} = mock_server, attrs) do
    mock_server
    |> MockServer.changeset(attrs)
    |> Repo.update()
  end

  def update_mock_server(_, _), do: {:error, :unauthorized}

  def delete_mock_server(%User{id: user_id}, %MockServer{user_id: user_id} = mock_server) do
    Repo.delete(mock_server)
  end

  def delete_mock_server(%Admin{}, %MockServer{} = mock_server) do
    Repo.delete(mock_server)
  end

  def delete_mock_server(_, _), do: {:error, :unauthorized}

  def change_mock_server(%MockServer{} = mock_server, attrs \\ %{}) do
    MockServer.changeset(mock_server, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  def toggle_mock_server(%User{id: user_id}, %MockServer{user_id: user_id, enabled: enabled?} = mock_server) do
    mock_server
    |> MockServer.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end

  def toggle_mock_server(_, _), do: {:error, :unauthorized}

  def scope(queryable, %User{id: user_id}) do
    queryable
    |> where([ms], ms.user_id == ^user_id)
  end

  def scope(queryable, %Admin{}), do: queryable

end
