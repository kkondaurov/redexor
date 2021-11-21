defmodule Redexor.ResponseTemplates do
  @moduledoc """
  The ResponseTemplates context.
  """

  import Ecto.Query, warn: false
  alias Redexor.Accounts.User
  alias Redexor.Admins.Admin
  alias Redexor.RdxRoutes.RdxRoute
  alias Redexor.Repo
  alias Redexor.ResponseTemplates.ResponseTemplate

  @spec list_responses(User.t() | Admin.t(), String.t()) :: [ResponseTemplate.t()]
  def list_responses(user, rdx_route_id) do
    ResponseTemplate
    |> scope(user)
    |> where([r], r.rdx_route_id == ^rdx_route_id)
    |> order_by([r], desc: r.id)
    |> Repo.all()
  end

  @spec get_response(User.t() | Admin.t(), String.t()) :: ResponseTemplate.t() | nil
  def get_response(user, id) do
    ResponseTemplate
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
          {:ok, ResponseTemplate.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def create_response(%User{id: user_id}, %RdxRoute{user_id: user_id} = rdx_route, attrs) do
    %ResponseTemplate{}
    |> Ecto.Changeset.change(rdx_route_id: rdx_route.id)
    |> ResponseTemplate.changeset(attrs)
    |> Repo.insert()
  end

  def create_response(%User{}, %RdxRoute{}, _attrs), do: {:error, :unauthorized}

  @spec update_response(User.t() | Admin.t(), RdxRoute.t(), map()) ::
          {:ok, RdxRoute.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def update_response(user, %ResponseTemplate{} = response_template, attrs) do
    if authorized?(user, response_template) do
      response_template
      |> ResponseTemplate.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  def update_response(%Admin{}, %ResponseTemplate{} = response_template, attrs) do
    response_template
    |> ResponseTemplate.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_response(User.t() | Admin.t(), ResponseTemplate.t()) ::
          {:ok, ResponseTemplate.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def delete_response(user, %ResponseTemplate{} = response_template) do
    if authorized?(user, response_template) do
      Repo.delete(response_template)
    else
      {:error, :unauthorized}
    end
  end

  @spec set_selected(User.t(), ResponseTemplate.t()) ::
          {:ok, ResponseTemplate.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def set_selected(
        %User{} = user,
        %ResponseTemplate{rdx_route_id: rdx_route_id, id: response_id} = response_template
      ) do
    if authorized?(user, response_template) do
      Ecto.Multi.new()
      |> Ecto.Multi.update_all(
        :reset_selected,
        from(r in ResponseTemplate,
          where: r.rdx_route_id == ^rdx_route_id and r.id != ^response_id
        ),
        set: [selected: false]
      )
      |> Ecto.Multi.update(:set_selected, fn _ ->
        Ecto.Changeset.change(response_template, %{selected: true})
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{set_selected: %ResponseTemplate{} = response_template}} ->
          {:ok, response_template}

        otherwise ->
          otherwise
      end
    else
      {:error, :unauthorized}
    end
  end

  defp authorized?(%User{id: user_id}, %ResponseTemplate{} = response_template) do
    %ResponseTemplate{
      rdx_route: %RdxRoute{user_id: rdx_route_user_id}
    } = Repo.preload(response_template, [:rdx_route])

    user_id == rdx_route_user_id
  end

  defp authorized?(%Admin{}, %ResponseTemplate{}), do: true

  @spec change_response(ResponseTemplate.t(), map) :: Ecto.Changeset.t()
  def change_response(%ResponseTemplate{} = response_template, attrs \\ %{}) do
    ResponseTemplate.changeset(response_template, attrs)
  end
end
