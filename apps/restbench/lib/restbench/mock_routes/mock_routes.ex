defmodule Restbench.MockRoutes do
  @moduledoc """
  The MockRoutes context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Accounts.User
  alias Restbench.Admins.Admin
  alias Restbench.MockRoutes.MockRoute
  alias Restbench.MockServers.MockServer
  alias Restbench.Repo

  @spec list_mock_routes(User.t(), String.t()) :: [MockRoute.t()]
  def list_mock_routes(user, mock_server_id) do
    MockRoute
    |> scope(user)
    |> where([r], r.mock_server_id == ^mock_server_id)
    |> order_by([r], desc: r.id)
    |> Repo.all()
  end

  @spec get_mock_route(User.t(), String.t()) :: MockRoute.t() | nil
  def get_mock_route(user, id) do
    MockRoute
    |> scope(user)
    |> Repo.get(id)
  end

  @spec create_mock_route(User.t() | Admin.t(), MockServer.t(), map()) :: {:ok, MockRoute.t()} | {:error, Ecto.Changeset.t()}
  def create_mock_route(%User{id: user_id}, %MockServer{id: mock_server_id}, attrs) do
    %MockRoute{}
    |> Ecto.Changeset.change(user_id: user_id)
    |> Ecto.Changeset.change(mock_server_id: mock_server_id)
    |> MockRoute.changeset(attrs)
    |> Repo.insert()
  end

  def create_mock_server(%Admin{}, attrs) do
    %MockRoute{}
    |> MockRoute.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_mock_route(User.t() | Admin.t(), MockServer.t(), map()) :: {:ok, MockRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_mock_route(%User{id: user_id}, %MockRoute{user_id: user_id} = mock_route, attrs) do
    mock_route
    |> MockRoute.changeset(attrs)
    |> Repo.update()
  end

  def update_mock_route(%Admin{}, %MockRoute{} = mock_route, attrs) do
    mock_route
    |> MockRoute.changeset(attrs)
    |> Repo.update()
  end

  def update_mock_route(_user, _mock_route, _attrs), do: {:error, :unauthorized}

  @spec delete_mock_route(User.t() | Admin.t(), MockRoute.t()) :: {:ok, MockRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_mock_route(%User{id: user_id}, %MockRoute{user_id: user_id} = mock_route) do
    Repo.delete(mock_route)
  end

  def delete_mock_route(%Admin{}, %MockRoute{} = mock_route) do
    Repo.delete(mock_route)
  end

  def delete_mock_route(_user, _mock_route), do: {:error, :unauthorized}

  @spec change_mock_route(MockRoute.t(), map) :: Ecto.Changeset.t()
  def change_mock_route(%MockRoute{} = mock_route, attrs \\ %{}) do
    MockRoute.changeset(mock_route, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  @spec toggle_mock_route(User.t(), MockRoute.t()) :: {:ok, MockRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def toggle_mock_route(%User{id: user_id}, %MockRoute{user_id: user_id, enabled: enabled?} = mock_route) do
    mock_route
    |> MockRoute.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end

  def toggle_mock_route(_user, _mock_route), do: {:error, :unauthorized}

  defp scope(queryable, %User{id: user_id}) do
    queryable
    |> where([mr], mr.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable
end
