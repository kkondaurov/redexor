defmodule Restbench.MockServersTest do
  use Restbench.DataCase

  alias Restbench.AccountsFixtures
  alias Restbench.MockServers

  setup do
    user = AccountsFixtures.user_fixture()
    {:ok, user: user}
  end

  describe "mock_servers" do
    alias Restbench.MockServers.MockServer

    import Restbench.MockServersFixtures

    @invalid_attrs %{enabled: nil, title: nil}

    test "list_mock_servers/1 returns all mock_servers", %{user: user} do
      mock_server = mock_server_fixture(user)
      assert [mock_server] == MockServers.list_mock_servers(user)
    end

    test "get_mock_server/2 returns the mock_server with given id", %{user: user} do
      mock_server = mock_server_fixture(user)
      assert mock_server == MockServers.get_mock_server(user, mock_server.id)
    end

    test "create_mock_server/2 with valid data creates a mock_server", %{user: user} do
      valid_attrs = %{enabled: true, title: "some title"}

      assert {:ok, %MockServer{} = mock_server} = MockServers.create_mock_server(user, valid_attrs)
      assert mock_server.enabled == true
      assert mock_server.title == "some title"
    end

    test "create_mock_server/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = MockServers.create_mock_server(user, @invalid_attrs)
    end

    test "update_mock_server/3 with valid data updates the mock_server", %{user: user} do
      mock_server = mock_server_fixture(user)
      update_attrs = %{enabled: false, title: "some updated title"}

      assert {:ok, %MockServer{} = mock_server} = MockServers.update_mock_server(user, mock_server, update_attrs)
      assert mock_server.enabled == false
      assert mock_server.title == "some updated title"
    end

    test "update_mock_server/3 with invalid data returns error changeset", %{user: user} do
      mock_server = mock_server_fixture(user)
      assert {:error, %Ecto.Changeset{}} = MockServers.update_mock_server(user, mock_server, @invalid_attrs)
      assert mock_server == MockServers.get_mock_server(user, mock_server.id)
    end

    test "delete_mock_server/2 deletes the mock_server", %{user: user} do
      mock_server = mock_server_fixture(user)
      assert {:ok, %MockServer{}} = MockServers.delete_mock_server(user, mock_server)
      assert is_nil(MockServers.get_mock_server(user, mock_server.id))
    end

    test "change_mock_server/2 returns a mock_server changeset", %{user: user} do
      mock_server = mock_server_fixture(user)
      assert %Ecto.Changeset{} = MockServers.change_mock_server(mock_server)
    end
  end
end
