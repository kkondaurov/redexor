defmodule Restbench.MockRoutesTest do
  use Restbench.DataCase

  alias Restbench.AccountsFixtures
  alias Restbench.MockRoutes
  alias Restbench.MockServersFixtures

  setup do
    user = AccountsFixtures.user_fixture()
    mock_server = MockServersFixtures.mock_server_fixture(user)
    {:ok, user: user, mock_server: mock_server}
  end

  describe "mock_routes" do
    alias Restbench.MockRoutes.MockRoute

    import Restbench.MockRoutesFixtures

    @invalid_attrs %{enabled: nil, method: nil, path: nil, title: nil}

    test "list_mock_routes/2 returns all mock_routes", %{user: user, mock_server: mock_server} do
      mock_route = mock_route_fixture(user, mock_server)
      assert MockRoutes.list_mock_routes(user, mock_server.id) == [mock_route]
    end

    test "get_mock_route!/1 returns the mock_route with given id", %{
      user: user,
      mock_server: mock_server
    } do
      mock_route = mock_route_fixture(user, mock_server)
      assert MockRoutes.get_mock_route(user, mock_route.id) == mock_route
    end

    test "create_mock_route/3 with valid data creates a mock_route", %{
      user: user,
      mock_server: mock_server
    } do
      valid_attrs = %{enabled: true, method: "GET", path: "some path", title: "some title"}

      assert {:ok, %MockRoute{} = mock_route} =
               MockRoutes.create_mock_route(user, mock_server, valid_attrs)

      assert mock_route.enabled == true
      assert mock_route.method == "GET"
      assert mock_route.path == "some path"
      assert mock_route.title == "some title"
    end

    test "create_mock_route/1 with invalid data returns error changeset", %{
      user: user,
      mock_server: mock_server
    } do
      assert {:error, %Ecto.Changeset{}} =
               MockRoutes.create_mock_route(user, mock_server, @invalid_attrs)
    end

    test "update_mock_route/2 with valid data updates the mock_route", %{
      user: user,
      mock_server: mock_server
    } do
      mock_route = mock_route_fixture(user, mock_server)

      update_attrs = %{
        enabled: false,
        method: "POST",
        path: "some updated path",
        title: "some updated title"
      }

      assert {:ok, %MockRoute{} = mock_route} =
               MockRoutes.update_mock_route(user, mock_route, update_attrs)

      assert mock_route.enabled == false
      assert mock_route.method == "POST"
      assert mock_route.path == "some updated path"
      assert mock_route.title == "some updated title"
    end

    test "update_mock_route/2 with invalid data returns error changeset", %{
      user: user,
      mock_server: mock_server
    } do
      mock_route = mock_route_fixture(user, mock_server)

      assert {:error, %Ecto.Changeset{}} =
               MockRoutes.update_mock_route(user, mock_route, @invalid_attrs)

      assert mock_route == MockRoutes.get_mock_route(user, mock_route.id)
    end

    test "delete_mock_route/2 deletes the mock_route", %{user: user, mock_server: mock_server} do
      mock_route = mock_route_fixture(user, mock_server)
      assert {:ok, %MockRoute{}} = MockRoutes.delete_mock_route(user, mock_route)
      assert is_nil(MockRoutes.get_mock_route(user, mock_route.id))
    end

    test "change_mock_route/2 returns a mock_route changeset", %{
      user: user,
      mock_server: mock_server
    } do
      mock_route = mock_route_fixture(user, mock_server)
      assert %Ecto.Changeset{} = MockRoutes.change_mock_route(mock_route)
    end
  end
end
