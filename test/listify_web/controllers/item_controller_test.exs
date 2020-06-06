defmodule ListifyWeb.ItemControllerTest do
  use ListifyWeb.ConnCase

  import Listify.Factory

  alias Listify.Repo
  alias Listify.Shopping.Item
  alias ListifyWeb.ShoppingUseCases

  describe "GET index" do
    test "lists all items sorted desc when no filters are given", %{conn: conn} do
      first_item =
        insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: -1), taken: false)

      second_item = insert(:item, inserted_at: DateTime.utc_now(), taken: true)

      response =
        conn
        |> get(Routes.item_path(conn, :index))
        |> json_response(:ok)

      expected_item_ids = [second_item.id, first_item.id]
      fetched_item_ids = response |> Enum.map(& &1["id"])

      assert expected_item_ids == fetched_item_ids
    end

    test "filters items by the taken attribute when it is given", %{conn: conn} do
      taken_item = insert(:item, taken: true)
      _not_taken_item = insert(:item, taken: false)

      response =
        conn
        |> get(Routes.item_path(conn, :index, %{"taken" => "true"}))
        |> json_response(:ok)

      [fetched_item] = response

      assert fetched_item["id"] == taken_item.id
    end

    test "sorts items asc when the param is given", %{conn: conn} do
      first_item =
        insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: -1), taken: false)

      second_item = insert(:item, inserted_at: DateTime.utc_now(), taken: true)

      response =
        conn
        |> get(Routes.item_path(conn, :index, %{"sort" => "asc"}))
        |> json_response(:ok)

      expected_item_ids = [first_item.id, second_item.id]
      fetched_item_ids = response |> Enum.map(& &1["id"])

      assert expected_item_ids == fetched_item_ids
    end
  end

  describe "POST create" do
    test "renders the new item and broadcasts its creation when params are valid", %{conn: conn} do
      params = string_params_for(:item)
      ShoppingUseCases.subscribe_to_items()

      conn
      |> post(Routes.item_path(conn, :create), params)
      |> json_response(:created)

      [item] = Repo.all(Item)
      assert_received {:new_item, ^item}
    end

    test "renders unprocessable entity when the params are invalid", %{conn: conn} do
      params = string_params_for(:item, name: nil)

      response =
        conn
        |> post(Routes.item_path(conn, :create), params)
        |> json_response(:unprocessable_entity)

      assert response == %{"errors" => %{"name" => ["can't be blank"]}}
    end
  end
end
