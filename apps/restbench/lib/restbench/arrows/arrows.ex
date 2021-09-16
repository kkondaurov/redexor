defmodule Restbench.Arrows do
  @moduledoc """
  The Arrows context.
  """

  import Ecto.Query, warn: false
  alias Restbench.Accounts.User
  alias Restbench.Admins.Admin
  alias Restbench.Arrows.Arrow
  alias Restbench.Repo
  alias Restbench.Servers.Server

  @spec list_arrows(User.t() | Admin.t(), String.t()) :: [Arrow.t()]
  def list_arrows(user, server_id) do
    Arrow
    |> scope(user)
    |> where([r], r.server_id == ^server_id)
    |> order_by([r], desc: r.id)
    |> Repo.all()
  end

  @spec get_arrow(User.t() | Admin.t(), String.t()) :: Arrow.t() | nil
  def get_arrow(user, id) do
    Arrow
    |> scope(user)
    |> Repo.get(id)
  end

  @spec create_arrow(User.t(), Server.t(), map()) ::
          {:ok, Arrow.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def create_arrow(%User{id: user_id}, %Server{id: server_id, user_id: user_id}, attrs) do
    %Arrow{}
    |> Ecto.Changeset.change(user_id: user_id)
    |> Ecto.Changeset.change(server_id: server_id)
    |> Arrow.changeset(attrs)
    |> Repo.insert()
  end

  def create_arrow(%User{}, %Server{}, _attrs), do: {:error, :unauthorized}

  @spec update_arrow(User.t() | Admin.t(), Arrow.t(), map()) ::
          {:ok, Arrow.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_arrow(%User{id: user_id}, %Arrow{user_id: user_id} = arrow, attrs) do
    arrow
    |> Arrow.changeset(attrs)
    |> Repo.update()
  end

  def update_arrow(%Admin{}, %Arrow{} = arrow, attrs) do
    arrow
    |> Arrow.changeset(attrs)
    |> Repo.update()
  end

  def update_arrow(_user, _arrow, _attrs), do: {:error, :unauthorized}

  @spec maybe_set_response(User.t() | Admin.t(), Arrow.t(), String.t()) ::
    {:ok, Arrow.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def maybe_set_response(user, %Arrow{response_id: nil} = arrow, response_id) do
    update_arrow(user, arrow, %{response_id: response_id})
  end

  def maybe_set_response(_user, arrow, _response_id), do: {:ok, arrow}

  @spec delete_arrow(User.t() | Admin.t(), Arrow.t()) ::
          {:ok, Arrow.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_arrow(%User{id: user_id}, %Arrow{user_id: user_id} = arrow) do
    Repo.delete(arrow)
  end

  def delete_arrow(%Admin{}, %Arrow{} = arrow) do
    Repo.delete(arrow)
  end

  def delete_arrow(_user, _arrow), do: {:error, :unauthorized}

  @spec change_arrow(Arrow.t(), map) :: Ecto.Changeset.t()
  def change_arrow(%Arrow{} = arrow, attrs \\ %{}) do
    Arrow.changeset(arrow, attrs)
  end

  @doc """
  Toggles `enabled` flag.
  """
  @spec toggle_arrow(User.t(), Arrow.t()) ::
          {:ok, Arrow.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def toggle_arrow(
        %User{id: user_id},
        %Arrow{user_id: user_id, enabled: enabled?} = arrow
      ) do
    arrow
    |> Arrow.changeset(%{enabled: not enabled?})
    |> Repo.update()
  end

  def toggle_arrow(_user, _arrow), do: {:error, :unauthorized}

  defp scope(queryable, %User{id: user_id}) do
    queryable
    |> where([mr], mr.user_id == ^user_id)
  end

  defp scope(queryable, %Admin{}), do: queryable

  @spec find_enabled_route(String.t(), String.t(), String.t()) :: Arrow.t() | nil
  def find_enabled_route(server_id, method, path) do
    Arrow
    |> where([r], r.server_id == ^server_id)
    |> join(:inner, [r], s in Server, on: s.id == r.server_id)
    |> where([r, _s], r.method == ^method and r.path == ^path)
    |> where([r, s], r.enabled and s.enabled)
    |> Repo.one()
    |> Repo.preload([:response])
  end
end
