defmodule Restbench.ServersTest do
  use Restbench.DataCase

  alias Restbench.AccountsFixtures
  alias Restbench.Servers

  setup do
    user = AccountsFixtures.user_fixture()
    {:ok, user: user}
  end

  describe "servers" do
    alias Restbench.Servers.Server

    import Restbench.ServersFixtures

    @invalid_attrs %{enabled: nil, title: nil}

    test "list_servers/1 returns all servers", %{user: user} do
      server = server_fixture(user)
      assert [server] == Servers.list_servers(user)
    end

    test "get_server/2 returns the server with given id", %{user: user} do
      server = server_fixture(user)
      assert server == Servers.get_server(user, server.id)
    end

    test "create_server/2 with valid data creates a server", %{user: user} do
      valid_attrs = %{enabled: true, title: "some title"}

      assert {:ok, %Server{} = server} = Servers.create_server(user, valid_attrs)

      assert server.enabled == true
      assert server.title == "some title"
    end

    test "create_server/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Servers.create_server(user, @invalid_attrs)
    end

    test "update_server/3 with valid data updates the server", %{user: user} do
      server = server_fixture(user)
      update_attrs = %{enabled: false, title: "some updated title"}

      assert {:ok, %Server{} = server} = Servers.update_server(user, server, update_attrs)

      assert server.enabled == false
      assert server.title == "some updated title"
    end

    test "update_server/3 with invalid data returns error changeset", %{user: user} do
      server = server_fixture(user)

      assert {:error, %Ecto.Changeset{}} = Servers.update_server(user, server, @invalid_attrs)

      assert server == Servers.get_server(user, server.id)
    end

    test "delete_server/2 deletes the server", %{user: user} do
      server = server_fixture(user)
      assert {:ok, %Server{}} = Servers.delete_server(user, server)
      assert is_nil(Servers.get_server(user, server.id))
    end

    test "change_server/2 returns a server changeset", %{user: user} do
      server = server_fixture(user)
      assert %Ecto.Changeset{} = Servers.change_server(server)
    end
  end
end
