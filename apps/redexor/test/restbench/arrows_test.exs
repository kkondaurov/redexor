defmodule Redexor.ArrowsTest do
  use Redexor.DataCase

  alias Redexor.Arrows
  alias Redexor.Support.AccountsFixtures
  alias Redexor.Support.ServersFixtures

  setup do
    user = AccountsFixtures.user_fixture()
    server = ServersFixtures.server_fixture(user)
    {:ok, user: user, server: server}
  end

  describe "arrows" do
    alias Redexor.Arrows.Arrow

    import Redexor.Support.ArrowsFixtures

    @invalid_attrs %{enabled: nil, method: nil, path: nil, title: nil}

    test "list_arrows/2 returns all arrows", %{user: user, server: server} do
      arrow = arrow_fixture(user, server)
      assert Arrows.list_arrows(user, server.id) == [arrow]
    end

    test "get_arrow/1 returns the arrow with given id", %{
      user: user,
      server: server
    } do
      %Arrow{id: arrow_id} = arrow_fixture(user, server)
      assert %Arrow{id: ^arrow_id} = Arrows.get_arrow(user, arrow_id)
    end

    test "create_arrow/3 with valid data creates a arrow", %{
      user: user,
      server: server
    } do
      valid_attrs = %{enabled: true, method: "GET", path: "/some path", title: "some title"}

      assert {:ok, %Arrow{} = arrow} = Arrows.create_arrow(user, server, valid_attrs)

      assert arrow.enabled == true
      assert arrow.method == "GET"
      assert arrow.path == "/some path"
      assert arrow.title == "some title"
    end

    test "create_arrow/1 with invalid data returns error changeset", %{
      user: user,
      server: server
    } do
      assert {:error, %Ecto.Changeset{}} = Arrows.create_arrow(user, server, @invalid_attrs)
    end

    test "update_arrow/2 with valid data updates the arrow", %{
      user: user,
      server: server
    } do
      arrow = arrow_fixture(user, server)

      update_attrs = %{
        enabled: false,
        method: "POST",
        path: "/some updated path",
        title: "some updated title"
      }

      assert {:ok, %Arrow{} = arrow} = Arrows.update_arrow(user, arrow, update_attrs)

      assert arrow.enabled == false
      assert arrow.method == "POST"
      assert arrow.path == "/some updated path"
      assert arrow.title == "some updated title"
    end

    test "update_arrow/2 with invalid data returns error changeset", %{
      user: user,
      server: server
    } do
      %Arrow{
        id: arrow_id,
        enabled: enabled,
        method: method,
        path: path,
        title: title
      } = arrow = arrow_fixture(user, server)

      assert {:error, %Ecto.Changeset{}} = Arrows.update_arrow(user, arrow, @invalid_attrs)

      assert %Arrow{
        id: ^arrow_id,
        enabled: ^enabled,
        method: ^method,
        path: ^path,
        title: ^title
      } = Arrows.get_arrow(user, arrow_id)
    end

    test "update_arrow/2 adds a leading slash", %{
      user: user,
      server: server
    } do
      arrow = arrow_fixture(user, server)

      assert {:ok, %Arrow{} = arrow} =
               Arrows.update_arrow(user, arrow, %{path: "path/without/leading/shash"})

      assert arrow.path == "/path/without/leading/shash"
    end

    test "update_arrow/2 with duplicate path and method", %{
      user: user,
      server: server
    } do
      arrow = arrow_fixture(user, server)

      assert {:error, %Ecto.Changeset{}} =
               Arrows.create_arrow(user, server, %{
                 title: "duplicate path and method",
                 path: arrow.path,
                 method: arrow.method,
                 enabled: true
               })

      assert {:error, %Ecto.Changeset{}} =
               Arrows.create_arrow(user, server, %{
                 title: "duplicate path and method",
                 path: arrow.path,
                 method: arrow.method,
                 enabled: false
               })
    end

    test "delete_arrow/2 deletes the arrow", %{user: user, server: server} do
      arrow = arrow_fixture(user, server)
      assert {:ok, %Arrow{}} = Arrows.delete_arrow(user, arrow)
      assert is_nil(Arrows.get_arrow(user, arrow.id))
    end

    test "change_arrow/2 returns a arrow changeset", %{
      user: user,
      server: server
    } do
      arrow = arrow_fixture(user, server)
      assert %Ecto.Changeset{} = Arrows.change_arrow(arrow)
    end
  end
end
