defmodule Restbench.MockServers do
  @moduledoc """
  The MockServers context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Accounts.User
  alias Restbench.Admins.Admin
  alias Restbench.MockServers.MockServer
  alias Restbench.Repo

  @spec list_mock_servers(User.t()) :: [MockServer.t()]
  def list_mock_servers(user) do
    MockServer
    |> scope(user)
    |> order_by([s], desc: s.id)
    |> Repo.all()
  end

  @spec get_mock_server(User.t(), String.t()) :: MockServer.t() | nil
  def get_mock_server(user, id) do
    MockServer
    |> scope(user)
    |> Repo.get(id)
  end

  @spec create_mock_server(User.t() | Admin.t(), map()) :: {:ok, MockServer.t()} | {:error, Ecto.Changeset.t()}
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

  @spec update_mock_server(User.t() | Admin.t(), MockServer.t(), map()) :: {:ok, MockServer.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
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

  def update_mock_server(_user, _mock_server, _attrs), do: {:error, :unauthorized}

  @spec delete_mock_server(User.t() | Admin.t(), MockServer.t()) :: {:ok, MockServer.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_mock_server(%User{id: user_id}, %MockServer{user_id: user_id} = mock_server) do
    Repo.delete(mock_server)
  end

  def delete_mock_server(%Admin{}, %MockServer{} = mock_server) do
    Repo.delete(mock_server)
  end

  def delete_mock_server(_user, _mock_server), do: {:error, :unauthorized}

  @spec change_mock_server(MockServer.t(), map()) :: Ecto.Changeset.t()
  def change_mock_server(%MockServer{} = mock_server, attrs \\ %{}) do
    MockServer.changeset(mock_server, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  @spec toggle_mock_server(User.t(), MockServer.t()) :: {:ok, MockServer.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def toggle_mock_server(%User{id: user_id}, %MockServer{user_id: user_id, enabled: enabled?} = mock_server) do
    mock_server
    |> MockServer.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end

  def toggle_mock_server(_, _), do: {:error, :unauthorized}

  defp scope(queryable, %User{id: user_id}) do
    queryable
    |> where([ms], ms.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable

end
