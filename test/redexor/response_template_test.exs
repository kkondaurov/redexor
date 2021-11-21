defmodule Redexor.ResponseTemplateTest do
  use ExUnit.Case

  alias Redexor.ResponseTemplates.ResponseTemplate

  @almost_valid_response %{
    title: "test title",
    rdx_route: "whatever",
    type: nil,
    code: 200,
    text_body: nil,
    json_body: nil
  }

  describe "ResponseTemplate" do
    test "changeset/2 allows empty in text_body for JSON type" do
      assert %Ecto.Changeset{valid?: true} =
               ResponseTemplate.changeset(%ResponseTemplate{}, %{
                 @almost_valid_response
                 | type: "JSON",
                   json_body: ~s({"foo": "bar"})
               })
    end

    test "changeset/2 allows empty string in text_body for JSON type" do
      assert %Ecto.Changeset{valid?: true} =
               ResponseTemplate.changeset(%ResponseTemplate{}, %{
                 @almost_valid_response
                 | type: "JSON",
                   json_body: ~s({"foo": "bar"}),
                   text_body: ""
               })
    end

    test "changeset/2 allows empty in json_body for TEXT type" do
      assert %Ecto.Changeset{valid?: true} =
               ResponseTemplate.changeset(%ResponseTemplate{}, %{
                 @almost_valid_response
                 | type: "TEXT",
                   text_body: "HELLO"
               })
    end

    test "changeset/2 allows empty string in json_body for TEXT type" do
      assert %Ecto.Changeset{valid?: true} =
               ResponseTemplate.changeset(%ResponseTemplate{}, %{
                 @almost_valid_response
                 | type: "TEXT",
                   text_body: "HELLO",
                   json_body: ""
               })
    end
  end
end
