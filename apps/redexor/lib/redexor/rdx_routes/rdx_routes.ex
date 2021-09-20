defmodule Redexor.RdxRoutes do
  @moduledoc """
  The RdxRoutes context.
  """

  import Ecto.Query, warn: false
  alias Redexor.Accounts.User
  alias Redexor.Admins.Admin
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.Repo
  alias Redexor.Responses.Response
  alias Redexor.Servers.Server

  @spec list_rdx_routes(User.t() | Admin.t(), String.t()) :: [RdxRoute.t()]
  def list_rdx_routes(user, server_id) do
    RdxRoute
    |> scope(user)
    |> where([r], r.server_id == ^server_id)
    |> order_by([r], desc: r.id)
    |> Repo.all()
  end

  @spec get_rdx_route(User.t() | Admin.t(), String.t()) :: RdxRoute.t() | nil
  def get_rdx_route(user, id) do
    RdxRoute
    |> scope(user)
    |> Repo.get(id)
    |> preload_selected_response()
  end

  @spec create_rdx_route(User.t(), Server.t(), map()) ::
          {:ok, RdxRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def create_rdx_route(%User{id: user_id}, %Server{id: server_id, user_id: user_id}, attrs) do
    %RdxRoute{}
    |> Ecto.Changeset.change(user_id: user_id)
    |> Ecto.Changeset.change(server_id: server_id)
    |> RdxRoute.changeset(attrs)
    |> Repo.insert()
  end

  def create_rdx_route(%User{}, %Server{}, _attrs), do: {:error, :unauthorized}

  @spec update_rdx_route(User.t() | Admin.t(), RdxRoute.t(), map()) ::
          {:ok, RdxRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_rdx_route(%User{id: user_id}, %RdxRoute{user_id: user_id} = rdx_route, attrs) do
    rdx_route
    |> RdxRoute.changeset(attrs)
    |> Repo.update()
  end

  def update_rdx_route(%Admin{}, %RdxRoute{} = rdx_route, attrs) do
    rdx_route
    |> RdxRoute.changeset(attrs)
    |> Repo.update()
  end

  def update_rdx_route(_user, _rdx_route, _attrs), do: {:error, :unauthorized}

  @spec delete_rdx_route(User.t() | Admin.t(), RdxRoute.t()) ::
          {:ok, RdxRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_rdx_route(%User{id: user_id}, %RdxRoute{user_id: user_id} = rdx_route) do
    Repo.delete(rdx_route)
  end

  def delete_rdx_route(%Admin{}, %RdxRoute{} = rdx_route) do
    Repo.delete(rdx_route)
  end

  def delete_rdx_route(_user, _rdx_route), do: {:error, :unauthorized}

  @spec change_rdx_route(RdxRoute.t(), map) :: Ecto.Changeset.t()
  def change_rdx_route(%RdxRoute{} = rdx_route, attrs \\ %{}) do
    RdxRoute.changeset(rdx_route, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  @spec toggle_rdx_route(User.t(), RdxRoute.t()) ::
          {:ok, RdxRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def toggle_rdx_route(
        %User{id: user_id},
        %RdxRoute{user_id: user_id, enabled: enabled?} = rdx_route
      ) do
    rdx_route
    |> RdxRoute.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end

  def toggle_rdx_route(_user, _rdx_route), do: {:error, :unauthorized}

  defp scope(queryable, %User{id: user_id}) do
    queryable
    |> where([mr], mr.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable

  @spec find_enabled_route(String.t(), String.t(), String.t()) :: RdxRoute.t() | nil
  def find_enabled_route(server_id, method, path) do
    RdxRoute
    |> where([r], r.server_id == ^server_id)
    |> join(:inner, [r], s in Server, on: s.id == r.server_id)
    |> where([r, _s], r.method == ^method and r.path == ^path)
    |> where([r, s], r.enabled and s.enabled)
    |> Repo.one()
    |> preload_selected_response()
  end

  @spec preload_selected_response(RdxRoute.t()) :: RdxRoute.t()
  def preload_selected_response(rdx_route) do
    Repo.preload(rdx_route, [response: from(r in Response, where: r.selected)])
  end
end
