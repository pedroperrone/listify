defmodule ListifyWeb.ItemControllerTest do
  use ListifyWeb.ConnCase

  import Listify.Factory

  alias Ecto.UUID
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

  describe "PATCH update" do
    test "renders the updated item and broadcasts its change when params are valid", %{conn: conn} do
      item = insert(:item)
      params = %{"name" => "Name after update"}
      ShoppingUseCases.subscribe_to_items()

      response =
        conn
        |> patch(Routes.item_path(conn, :update, item.id), params)
        |> json_response(:ok)

      item = Repo.get(Item, item.id)
      assert response["name"] == "Name after update"
      assert item.name == "Name after update"
      assert_received {:updated_item, ^item}
    end

    test "renders unprocessable entity when the params are invalid", %{conn: conn} do
      item = insert(:item)
      params = %{"name" => nil}

      response =
        conn
        |> patch(Routes.item_path(conn, :update, item.id), params)
        |> json_response(:unprocessable_entity)

      assert response == %{"errors" => %{"name" => ["can't be blank"]}}
    end

    test "renders not found when the item does not exist", %{conn: conn} do
      response =
        conn
        |> patch(Routes.item_path(conn, :update, UUID.generate()), %{})
        |> json_response(:not_found)

      assert response == %{"errors" => %{"detail" => "The item does not exist"}}
    end
  end

  describe "DELETE delete" do
    test "delete the item when it exists", %{conn: conn} do
      item = insert(:item)
      ShoppingUseCases.subscribe_to_items()

      conn
      |> delete(Routes.item_path(conn, :delete, item.id))
      |> response(:no_content)

      assert Item |> Repo.get(item.id) |> is_nil()

      item_id = item.id
      assert_received {:deleted_item, %Item{id: ^item_id}}
    end

    test "renders not found when the item does not exist", %{conn: conn} do
      response =
        conn
        |> delete(Routes.item_path(conn, :delete, UUID.generate()))
        |> json_response(:not_found)

      assert response == %{"errors" => %{"detail" => "The item does not exist"}}
    end
  end
end
