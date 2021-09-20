defmodule Redexor.Responses do
  @moduledoc """
  The Responses context.
  """

  import Ecto.Query, warn: false
  alias Redexor.Accounts.User
  alias Redexor.Admins.Admin
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.Repo
  alias Redexor.Responses.Response

  @spec list_responses(User.t() | Admin.t(), String.t()) :: [Response.t()]
  def list_responses(user, rdx_route_id) do
    Response
    |> scope(user)
    |> where([r], r.rdx_route_id == ^rdx_route_id)
    |> order_by([r], desc: r.id)
    |> Repo.all()
  end

  @spec get_response(User.t() | Admin.t(), String.t()) :: Response.t() | nil
  def get_response(user, id) do
    Response
    |> scope(user)
    |> Repo.get(id)
  end

  defp scope(queryable, %User{id: user_id}) do
    queryable
    |> join(:inner, [r], a in RdxRoute, on: a.id == r.rdx_route_id)
    |> where([_r, a], a.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable


  @spec create_response(User.t(), RdxRoute.t(), map()) ::
          {:ok, Response.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def create_response(%User{id: user_id}, %RdxRoute{user_id: user_id} = rdx_route, attrs) do
    %Response{}
    |> Ecto.Changeset.change(rdx_route_id: rdx_route.id)
    |> Response.changeset(attrs)
    |> Repo.insert()
  end

  def create_response(%User{}, %RdxRoute{}, _attrs), do: {:error, :unauthorized}

  @spec update_response(User.t() | Admin.t(), RdxRoute.t(), map()) ::
          {:ok, RdxRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_response(user, %Response{} = response, attrs) do
    if authorized?(user, response) do
      response
      |> Response.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  def update_response(%Admin{}, %Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_response(User.t() | Admin.t(), Response.t()) ::
          {:ok, Response.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_response(user, %Response{} = response) do
    if authorized?(user, response) do
      Repo.delete(response)
    else
      {:error, :unauthorized}
    end
  end

  @spec set_selected(User.t(), Response.t()) ::
    {:ok, Response.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def set_selected(%User{} = user, %Response{rdx_route_id: rdx_route_id, id: response_id} = response) do
    if authorized?(user, response) do
      Ecto.Multi.new()
      |> Ecto.Multi.update_all(:reset_selected, from(r in Response, where: r.rdx_route_id == ^rdx_route_id and r.id != ^response_id), set: [selected: false])
      |> Ecto.Multi.update(:set_selected, fn _ ->
        Ecto.Changeset.change(response, %{selected: true})
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{set_selected: %Response{} = response}} -> {:ok, response}
        otherwise -> otherwise
      end
    else
      {:error, :unauthorized}
    end
  end

  defp authorized?(%User{id: user_id}, %Response{} = response) do
    %Response{
     rdx_route: %RdxRoute{user_id: rdx_route_user_id}
    } = Repo.preload(response, [:rdx_route])
    user_id == rdx_route_user_id
  end

  defp authorized?(%Admin{}, %Response{}), do: true

  @spec change_response(Response.t(), map) :: Ecto.Changeset.t()
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

end
