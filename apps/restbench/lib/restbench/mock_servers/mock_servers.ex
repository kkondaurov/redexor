defmodule Restbench.MockServers do
  @moduledoc """
  The MockServers context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Repo

  alias Restbench.MockServers.MockServer

  @doc """
  Returns the list of mock_servers.

  ## Examples

      iex> list_mock_servers()
      [%MockServer{}, ...]

  """
  def list_mock_servers do
    Repo.all(MockServer)
  end

  @doc """
  Gets a single mock_server.

  Raises `Ecto.NoResultsError` if the Mock server does not exist.

  ## Examples

      iex> get_mock_server!(123)
      %MockServer{}

      iex> get_mock_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mock_server!(id), do: Repo.get!(MockServer, id)

  @doc """
  Creates a mock_server.

  ## Examples

      iex> create_mock_server(%{field: value})
      {:ok, %MockServer{}}

      iex> create_mock_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mock_server(attrs \\ %{}) do
    %MockServer{}
    |> MockServer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mock_server.

  ## Examples

      iex> update_mock_server(mock_server, %{field: new_value})
      {:ok, %MockServer{}}

      iex> update_mock_server(mock_server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mock_server(%MockServer{} = mock_server, attrs) do
    mock_server
    |> MockServer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mock_server.

  ## Examples

      iex> delete_mock_server(mock_server)
      {:ok, %MockServer{}}

      iex> delete_mock_server(mock_server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mock_server(%MockServer{} = mock_server) do
    Repo.delete(mock_server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mock_server changes.

  ## Examples

      iex> change_mock_server(mock_server)
      %Ecto.Changeset{data: %MockServer{}}

  """
  def change_mock_server(%MockServer{} = mock_server, attrs \\ %{}) do
    MockServer.changeset(mock_server, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  def toggle_mock_server(%MockServer{enabled: enabled?} = mock_server) do
    mock_server
    |> MockServer.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end
end
