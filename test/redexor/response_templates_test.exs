defmodule Redexor.ResponseTemplatesTest do
  use Redexor.DataCase

  alias Redexor.ResponseTemplates
  alias Redexor.ResponseTemplates.ResponseTemplate
  alias Redexor.Support.{AccountsFixtures, RdxRoutesFixtures, ServersFixtures}

  setup do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    rdx_route = RdxRoutesFixtures.rdx_route_fixture(user, server)
    {:ok, user: user, server: server, rdx_route: rdx_route}
  end

  describe "ResponseTemplates" do
    test "given a route without response_templates, a created response_template is listed for the route",
         %{user: user, rdx_route: rdx_route} do
      {:ok, response_template} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "TEXT",
          text_body: "hello world!",
          title: "response_template title"
        })

      assert ResponseTemplates.list_responses(user, rdx_route.id) == [response_template]
    end

    test "create_response/2 validates TEXT type", %{user: user, rdx_route: rdx_route} do
      assert {:error, %Ecto.Changeset{}} =
               ResponseTemplates.create_response(user, rdx_route, %{
                 code: 403,
                 type: "TEXT",
                 title: "response_template title"
               })

      assert {:error, %Ecto.Changeset{}} =
               ResponseTemplates.create_response(user, rdx_route, %{
                 code: 403,
                 type: "TEXT",
                 json_body: "{\"foo\":\"bar\"}",
                 title: "response_template title"
               })

      {:ok, _response} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "TEXT",
          text_body: "hello world!",
          title: "response_template title"
        })
    end

    test "create_response/2 validates JSON type", %{user: user, rdx_route: rdx_route} do
      assert {:error, %Ecto.Changeset{}} =
               ResponseTemplates.create_response(user, rdx_route, %{
                 code: 403,
                 type: "JSON",
                 title: "response_template title"
               })

      assert {:error, %Ecto.Changeset{}} =
               ResponseTemplates.create_response(user, rdx_route, %{
                 code: 403,
                 type: "JSON",
                 text_body: "hello world",
                 title: "response_template title"
               })

      {:ok, _response} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "JSON",
          json_body: "{\"foo\":\"bar\"}",
          title: "response_template title"
        })
    end

    test "delete_response/2 deletes proper response_template", %{user: user, rdx_route: rdx_route} do
      {:ok, first_response} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "TEXT",
          text_body: "first_response",
          title: "first_response"
        })

      {:ok, %{id: second_response_id} = second_response} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 404,
          type: "TEXT",
          text_body: "second_response",
          title: "second_response"
        })

      assert {:ok, %ResponseTemplate{id: ^second_response_id}} =
               ResponseTemplates.delete_response(user, second_response)

      assert ResponseTemplates.list_responses(user, rdx_route.id) == [first_response]
    end

    test "set_selected/2 selects given response_template", %{user: user, rdx_route: rdx_route} do
      {:ok, first_response} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 403,
          type: "TEXT",
          text_body: "first_response",
          title: "first_response"
        })

      {:ok, %{id: second_response_id} = second_response} =
        ResponseTemplates.create_response(user, rdx_route, %{
          code: 404,
          type: "TEXT",
          text_body: "second_response",
          title: "second_response"
        })

      assert {:ok, %ResponseTemplate{id: ^second_response_id, selected: true}} =
               ResponseTemplates.set_selected(user, second_response)

      assert %ResponseTemplate{selected: false} =
               ResponseTemplates.get_response(user, first_response.id)
    end
  end
end
