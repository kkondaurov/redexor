defmodule Redexor.ResponsesTest do
  use Redexor.DataCase

  alias Redexor.Responses
  alias Redexor.Responses.Response
  alias Redexor.Support.AccountsFixtures
  alias Redexor.Support.ServersFixtures
  alias Redexor.Support.ArrowsFixtures

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

    test "delete_response/2 deletes proper response", %{user: user, arrow: arrow} do
      {:ok, first_response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "first_response",
        title: "first_response"
      })

      {:ok, %{id: second_response_id} = second_response} = Responses.create_response(user, arrow, %{
        code: 404,
        type: "TEXT",
        text_body: "second_response",
        title: "second_response"
      })
      assert {:ok, %Response{id: ^second_response_id}} = Responses.delete_response(user, second_response)
      assert Responses.list_responses(user, arrow.id) == [first_response]
    end

    test "set_selected/2 selects given response", %{user: user, arrow: arrow} do
      {:ok, first_response} = Responses.create_response(user, arrow, %{
        code: 403,
        type: "TEXT",
        text_body: "first_response",
        title: "first_response"
      })

      {:ok, %{id: second_response_id} = second_response} = Responses.create_response(user, arrow, %{
        code: 404,
        type: "TEXT",
        text_body: "second_response",
        title: "second_response"
      })
      assert {:ok, %Response{id: ^second_response_id, selected: true}} = Responses.set_selected(user, second_response)
      assert %Response{selected: false} = Responses.get_response(user, first_response.id)
    end
  end
end
