defmodule Restbench.MockServersTest do
  use Restbench.DataCase

  alias Restbench.MockServers

  describe "mock_servers" do
    alias Restbench.MockServers.MockServer

    import Restbench.MockServersFixtures

    @invalid_attrs %{enabled: nil, title: nil}

    test "list_mock_servers/0 returns all mock_servers" do
      mock_server = mock_server_fixture()
      assert MockServers.list_mock_servers() == [mock_server]
    end

    test "get_mock_server!/1 returns the mock_server with given id" do
      mock_server = mock_server_fixture()
      assert MockServers.get_mock_server!(mock_server.id) == mock_server
    end

    test "create_mock_server/1 with valid data creates a mock_server" do
      valid_attrs = %{enabled: true, title: "some title"}

      assert {:ok, %MockServer{} = mock_server} = MockServers.create_mock_server(valid_attrs)
      assert mock_server.enabled == true
      assert mock_server.title == "some title"
    end

    test "create_mock_server/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MockServers.create_mock_server(@invalid_attrs)
    end

    test "update_mock_server/2 with valid data updates the mock_server" do
      mock_server = mock_server_fixture()
      update_attrs = %{enabled: false, title: "some updated title"}

      assert {:ok, %MockServer{} = mock_server} = MockServers.update_mock_server(mock_server, update_attrs)
      assert mock_server.enabled == false
      assert mock_server.title == "some updated title"
    end

    test "update_mock_server/2 with invalid data returns error changeset" do
      mock_server = mock_server_fixture()
      assert {:error, %Ecto.Changeset{}} = MockServers.update_mock_server(mock_server, @invalid_attrs)
      assert mock_server == MockServers.get_mock_server!(mock_server.id)
    end

    test "delete_mock_server/1 deletes the mock_server" do
      mock_server = mock_server_fixture()
      assert {:ok, %MockServer{}} = MockServers.delete_mock_server(mock_server)
      assert_raise Ecto.NoResultsError, fn -> MockServers.get_mock_server!(mock_server.id) end
    end

    test "change_mock_server/1 returns a mock_server changeset" do
      mock_server = mock_server_fixture()
      assert %Ecto.Changeset{} = MockServers.change_mock_server(mock_server)
    end
  end
end
