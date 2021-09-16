defmodule Restbench.ResponsesTest do
  use Restbench.DataCase

  alias Restbench.Arrows
  alias Restbench.Responses
  alias Restbench.Responses.Response
  alias Restbench.Support.AccountsFixtures
  alias Restbench.Support.ServersFixtures
  alias Restbench.Support.ArrowsFixtures

  setup do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    arrow = ArrowsFixtures.arrow_fixture(user, server)
    {:ok, user: user, server: server, arrow: arrow}
  end

  describe "arrows" do

    test "given a route without responses, a created response is listed for the route", %{user: user, arrow: arrow} do
      {:ok, response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "hello world!",
        title: "response title"
      })
      assert Responses.list_responses(user, arrow.id) == [response]
    end

    test "create_response/2 validates TEXT type", %{user: user, arrow: arrow} do
      assert {:error, %Ecto.Changeset{}} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        title: "response title"
      })

      assert {:error, %Ecto.Changeset{}} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        json_body: "{\"foo\":\"bar\"}",
        title: "response title"
      })

      {:ok, _response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "hello world!",
        title: "response title"
      })
    end

    test "create_response/2 validates JSON type", %{user: user, arrow: arrow} do
      assert {:error, %Ecto.Changeset{}} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "JSON",
        title: "response title"
      })

      assert {:error, %Ecto.Changeset{}} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "JSON",
        text_body: "hello world",
        title: "response title"
      })

      {:ok, _response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "JSON",
        json_body: "{\"foo\":\"bar\"}",
        title: "response title"
      })
    end

    test "cannot delete response that is route's default", %{user: user, arrow: arrow} do
      {:ok, response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "hello world!",
        title: "response title"
      })
      {:ok, _arrow} = Arrows.maybe_set_response(user, arrow, response.id)
      assert_raise Ecto.ConstraintError, fn ->
        Responses.delete_response(user, response)
      end
    end

    test "can delete response that is not route's default", %{user: user, arrow: arrow} do
      {:ok, default_response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "hello world!",
        title: "default response"
      })
      {:ok, _arrow} = Arrows.maybe_set_response(user, arrow, default_response.id)

      {:ok, %{id: non_default_response_id} = non_default_response} = Responses.create_response(user, arrow, %{
        code: 404,
        type: "TEXT",
        text_body: "whatever!",
        title: "non-default response"
      })
      assert {:ok, %Response{id: ^non_default_response_id}} = Responses.delete_response(user, non_default_response)
      assert Responses.list_responses(user, arrow.id) == [default_response]
    end
  end
end
