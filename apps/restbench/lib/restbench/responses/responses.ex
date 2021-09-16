defmodule Restbench.Responses do
  @moduledoc """
  The Responses context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Accounts.User
  alias Restbench.Admins.Admin
  alias Restbench.Arrows.Arrow
  alias Restbench.Repo
  alias Restbench.Responses.Response

  @spec list_responses(User.t() | Admin.t(), String.t()) :: [Response.t()]
  def list_responses(user, arrow_id) do
    Response
    |> scope(user)
    |> where([r], r.arrow_id == ^arrow_id)
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
    |> join(:inner, [r], a in Arrow, on: a.id == r.arrow_id)
    |> where([_r, a], a.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable


  @spec create_response(User.t(), Arrow.t(), map()) ::
          {:ok, Response.t()} | {:error, Ecto.Changeset.t()}
  def create_response(%User{id: user_id}, %Arrow{id: arrow_id, user_id: user_id}, attrs) do
    %Response{}
    |> Ecto.Changeset.change(arrow_id: arrow_id)
    |> Response.changeset(attrs)
    |> Repo.insert()
  end

  def create_response(%User{}, %Arrow{}, _attrs), do: {:error, :unauthorized}

  @spec update_response(User.t() | Admin.t(), Arrow.t(), map()) ::
          {:ok, Arrow.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_response(%User{} = user, %Response{} = response, attrs) do
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
  def delete_response(%User{} = user, %Response{} = response) do
    if authorized?(user, response) do
      Repo.delete(response)
    else
      {:error, :unauthorized}
    end
  end

  def delete_response(%Admin{}, %Response{} = response) do
    Repo.delete(response)
  end

  defp authorized?(%User{id: user_id}, %Response{} = response) do
    %Response{
     arrow: %Arrow{user_id: arrow_user_id}
    } = Repo.preload(response, [:arrow])
    user_id == arrow_user_id
  end

  @spec change_response(Response.t(), map) :: Ecto.Changeset.t()
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

end
